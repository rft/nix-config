{ delib, pkgs, lib, ... }:
let
  # SFTP chroot root for the document scanner. sshd refuses to chroot into a
  # path it doesn't own, so this stays root-owned and the paperless consume
  # dir is nested inside it.
  scanDir = "/var/lib/scan";

  # One subdir per scanner profile — PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS turns
  # each directory name into a paperless tag on ingest.
  scanTags = [ "receipts" "tax" "manuals" ];

  # Shared baseline for all service sandboxes
  hardenedServiceConfig = {
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RestrictNamespaces = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = false;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@mount"
      "~@reboot"
      "~@swap"
    ];
  };
in
delib.module {
  name = "services";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      mosquitto # mosquitto_passwd / mosquitto_sub for broker bootstrap + debugging
    ];

    # Borgmatic backups of /srv/share and the state of the services below.
    # /srv/projects is left out on purpose — it lives in remote git repos.
    # Upstream ships the daily timer and a sandboxed unit (ProtectSystem=full,
    # so /var stays writable for the repo below).
    #
    # The repo is local for now — same disk as the sources, so this guards
    # against deletion/corruption, not drive failure. Add an off-machine entry
    # to `repositories` to fix that; borgmatic backs up to each in turn.
    #
    # One-time bootstrap (see docs/SERVICES.md):
    #   install -m 0400 /dev/stdin /var/lib/borgmatic/passphrase
    #   borgmatic repo-create --encryption repokey-blake2
    services.borgmatic = {
      enable = true;
      settings = {
        # DynamicUser services are listed by their real /var/lib/private path:
        # borg archives the /var/lib/<name> symlink itself, not its target.
        source_directories = [
          "/srv/share"
          "/var/lib/hass"
          "/var/lib/zigbee2mqtt" # coordinator state; losing it means re-pairing
          "/var/lib/zigbee2mqtt-mqtt.env"
          "/var/lib/mosquitto" # password files + retained messages
          "/var/lib/paperless"
          "/var/lib/private/n8n"
          "/var/lib/karakeep"
          "/var/lib/changedetection-io"
          "/var/lib/jellyfin"
          "/var/lib/private/9router" # provider logins / OAuth tokens
          "/var/lib/samba/private" # smbpasswd database
        ];
        repositories = [{ path = "/var/lib/borg/bristlecone"; label = "local"; }];

        # A plain file rather than the unit's LoadCredentialEncrypted, so
        # manual `sudo borgmatic list/extract` works outside systemd too.
        encryption_passcommand = "cat /var/lib/borgmatic/passphrase";

        # Live SQLite files can be torn mid-write, so each is dumped by the
        # hook and the raw file (plus -wal/-shm) excluded below. The hook runs
        # sqlite3 as root and a missing path gets created empty, so keep these
        # in sync with where the services actually put their DBs.
        sqlite_databases = [
          { name = "home-assistant"; path = "/var/lib/hass/home-assistant_v2.db"; }
          { name = "paperless"; path = "/var/lib/paperless/db.sqlite3"; }
          { name = "n8n"; path = "/var/lib/private/n8n/.n8n/database.sqlite"; }
          { name = "karakeep"; path = "/var/lib/karakeep/db.db"; }
          { name = "jellyfin"; path = "/var/lib/jellyfin/data/jellyfin.db"; }
        ];

        exclude_patterns = [
          "/var/lib/hass/home-assistant_v2.db*"
          "/var/lib/hass/*.log*"
          "/var/lib/hass/backups" # HA's own backups duplicate everything here
          "/var/lib/hass/tts"
          "/var/lib/paperless/db.sqlite3*"
          "/var/lib/paperless/celerybeat-schedule.db*"
          "/var/lib/paperless/index" # rebuildable: paperless-manage document_index reindex
          "/var/lib/paperless/log"
          "/var/lib/paperless/consume"
          "/var/lib/private/n8n/.n8n/database.sqlite*"
          "/var/lib/private/n8n/.cache"
          "/var/lib/karakeep/db.db*"
          "/var/lib/karakeep/queue.db*" # job queue, transient
          "/var/lib/jellyfin/data/jellyfin.db*"
          "/var/lib/jellyfin/log"
        ];
        exclude_caches = true;

        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 6;

        checks = [
          { name = "repository"; frequency = "2 weeks"; }
          { name = "archives"; frequency = "1 month"; }
        ];
      };
    };
    # Upstream bounds root to CAP_DAC_READ_SEARCH (read-only), but even a
    # .dump of a live WAL-mode DB must write the service-owned -shm file, so
    # sqlite3 fails with "attempt to write a readonly database" (seen on
    # jellyfin.db). Bounding-set assignments are additive, so this extends
    # upstream's list rather than replacing it.
    systemd.services.borgmatic.serviceConfig.CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];

    # Jellyfin media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Mosquitto MQTT broker. Home Assistant talks to it over localhost; IoT
    # devices reach it from the LAN, so 1883 is firewall-opened below.
    #
    # No blanket `pattern readwrite #`: patterns apply to every authenticated
    # user, which would make the per-user ACLs below meaningless. Anonymous
    # access is already off (mosquitto 2.x default), so each client
    # authenticates as a named user and gets only the topics it needs.
    services.mosquitto = {
      enable = true;
      listeners = [{
        users.hass = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = "/var/lib/mosquitto/hass-password";
        };
        # Livegrid OpenMatrix LED panel. It publishes its own HA discovery
        # payloads under homeassistant/ and subscribes to homeassistant/status
        # to re-announce after a restart; its own state lives under livegrid/.
        # https://livegrid.github.io/mqtt/
        users.livegrid = {
          acl = [
            "readwrite livegrid/#"
            "readwrite homeassistant/#"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/livegrid-password";
        };
        # Zigbee2MQTT. Its own state lives under zigbee2mqtt/; it also needs
        # homeassistant/# to publish MQTT discovery payloads for every paired
        # device and to watch homeassistant/status for HA restarts.
        users.zigbee2mqtt = {
          acl = [
            "readwrite zigbee2mqtt/#"
            "readwrite homeassistant/#"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/zigbee2mqtt-password";
        };
      }];
    };

    # Home Assistant
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        "hue"
        "xiaomi_miio"
        "google_translate"
        "met"
        "mqtt"
        "esphome"
        "cast"
        "radio_browser"
        # AirGradient ONE (I-9PSL) indoor monitors. Local polling over the
        # device's HTTP API — no cloud account and no MQTT involved. Needs
        # device firmware >= 3.1.1.
        "airgradient"
      ];
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "America/Phoenix";
        };
        default_config = {};

        # The UI editors write to these files and then reload; without the
        # matching !include they are never read, so a saved automation/script/
        # scene never materialises and the frontend times out waiting for it.
        # configuration.yaml itself is a read-only store symlink, so the
        # includes have to be declared here rather than added from the UI.
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml";
      };
    };

    # !include on a missing file aborts startup, so seed the UI-managed files
    # before hass reads the config. Runs as the hass user in configDir.
    systemd.services.home-assistant.preStart = lib.mkAfter ''
      for f in automations.yaml scripts.yaml scenes.yaml; do
        [ -e "/var/lib/hass/$f" ] || echo "[]" > "/var/lib/hass/$f"
      done
    '';

    # Zigbee2MQTT, driving the SONOFF Dongle Plus MG24 (Silicon Labs EFR32MG24
    # behind a CP2102N UART bridge) as the Zigbee coordinator.
    #
    # Chosen over ZHA because the Third Reality Smart Plug Gen3 (3RSP02064Z)
    # converter here exposes the full metering set plus metering_only_mode and
    # the power rise/drop thresholds; ZHA still lacks the latter two
    # (zigpy/zha-device-handlers#4844). HA needs no config change either way —
    # the mqtt component is already loaded and picks devices up via discovery.
    services.zigbee2mqtt = {
      enable = true;
      settings = {
        serial = {
          # by-id rather than /dev/ttyUSB0, which moves if another USB serial
          # device enumerates first. The module derives its DeviceAllow from
          # this path; systemd stat()s through the symlink, so it still
          # resolves to the 188:0 char device.
          port = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_2a7b2307dda2ef11902a8e6661ce3355-if00-port0";
          adapter = "ember"; # EFR32MG24 runs EmberZNet, not zstack
          baudrate = 115200; # stock SONOFF firmware; community builds use 460800
          rtscts = false;
        };
        mqtt.server = "mqtt://localhost:1883";
        # mqtt.user/password deliberately absent — they come from the
        # EnvironmentFile below rather than the world-readable store.
        frontend = {
          enabled = true;
          port = 8080;
        };
        advanced.log_level = "info";
        # homeassistant.enabled already defaults to services.home-assistant.enable.
      };
    };

    # ZIGBEE2MQTT_CONFIG_MQTT_USER / _PASSWORD override the generated YAML
    # (applyEnvironmentVariables in z2m's settings.js). systemd reads this as
    # root before dropping to the zigbee2mqtt user, so 0400 root:root is fine.
    # Created out-of-band like the mosquitto password files.
    systemd.services.zigbee2mqtt.serviceConfig.EnvironmentFile =
      "/var/lib/zigbee2mqtt-mqtt.env";

    # n8n workflow automation
    services.n8n = {
      enable = true;
      openFirewall = true;
      environment.N8N_SECURE_COOKIE = "false";
    };

    # Paperless document management
    # The consume dir lives under /var/lib/scan (not the default
    # /var/lib/paperless/consume) so sshd can chroot the scanner user into a
    # root-owned parent. Upstream derives ReadWritePaths from consumptionDir,
    # so the relocation needs no hardening change below.
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      consumptionDir = "${scanDir}/consume";
      consumptionDirIsPublic = true; # mode 0777 so the scanner can drop files
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      };
    };

    # Brother ADS-1700W ingest: the scanner pushes finished PDFs over SFTP
    # (primary) or SMB (fallback) into a per-tag subdir of the consume dir.
    users.groups.scanner = { };
    users.users.scanner = {
      isSystemUser = true;
      group = "scanner";
      home = scanDir;
      createHome = false;
      # Safe with SFTP: sshd implements internal-sftp in-process and never
      # execs the login shell.
      shell = "${pkgs.shadow}/bin/nologin";
      # Generated on the scanner under Network > Security > Client Key Pair and
      # exported from Web Based Management. A public key, so it belongs in Nix
      # for the same reason myconfig.constants.sshKeys does.
      # RSA 2048, SHA256:QWsjjN2g4Y+sv1iZtrTUnS640Vn4nwp1UFbcBZ0gSg0
      # The comment is the scanner's own hostname (BR + its MAC).
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfTXHWsyvbt5qyT+1TecbgJrKBDHLP017k2ebfepreRD4SFicEbXaN4MS1WUhGNNNFYefvApDbhCskwJ3obe4PLPVFubfKsgWr8DpvaPuJQJc+vS8WH/lxReO7RvRDv0OhfY4oq0NgyAv4YNcUZGmSnuRfb3wTJe+HzNqFjwmuFSd8mZeNVifDuSGX8Mk8XaZ41M4iCYpNPidbWntK8AsF7Fck/FA9ebrWFckwkTGw8qqmOAgYXj0o+2VnfZsD+wb6OcUkHqWgEnPs7uoy+ufMoXNJpnEdQzf2QqLsLc9A4UgFdOiMn3Mu/RUbcLrqBc38pcVxD9cX91kOOBjqFyUP root@BR5CF370C3AC5A"
      ];
    };

    # The ADS-1700W only accepts an RSA server host key (it rejects the ed25519
    # one outright) and only offers the legacy SHA-1 `ssh-rsa` host key
    # algorithm, which OpenSSH has not offered by default since 8.8. Without
    # this the scanner fails with "no matching host key type found".
    #
    # This is host-wide, not scoped: HostKeyAlgorithms is not a valid Match
    # keyword. `+ssh-rsa` appends to the defaults, so modern clients still
    # negotiate ed25519/rsa-sha2 and only ever fall back to SHA-1 if they ask
    # for it. It weakens host *authentication* only — user pubkey auth is
    # governed separately by PubkeyAcceptedAlgorithms and is untouched.
    # Drop this line if the SMB transport ever replaces SFTP here.
    services.openssh.settings.HostKeyAlgorithms = "+ssh-rsa";

    # Same story for MACs: the scanner offers only non-ETM algorithms
    # (hmac-sha2-256/512 plus sha1/md5/ripemd160 variants), while the default
    # list here is ETM-only — an empty intersection, so the connection dies at
    # "no matching MAC found" before authentication is even attempted.
    # Appending just the two SHA-2 non-ETM variants keeps the SHA-1 and MD5
    # ones the firmware also offers off the table. Encrypt-and-MAC rather than
    # encrypt-then-MAC is a real but modest downgrade, and only for clients
    # that can't do better — the ETM entries stay first in the list.
    # Macs is not a valid Match keyword either, hence global.
    services.openssh.settings.Macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
    ];

    # internal-sftp is required, not stylistic: the global `Subsystem sftp`
    # points at a /nix/store binary that doesn't exist inside the chroot.
    # -u 0022 makes uploads 0644 so paperless-consumer can read them.
    # mkAfter keeps the Match block last — every directive after a Match
    # belongs to it. Ciphers/MACs/KexAlgorithms cannot go in a Match block; if
    # the scanner can't negotiate, widen them globally (see docs/SERVICES.md).
    #
    # PubkeyAcceptedAlgorithms *is* a valid Match keyword, so the firmware's
    # SHA-1 ssh-rsa user-auth signatures are accepted for this account alone —
    # every other user on the host keeps the SHA-2-only default. Without it:
    # "signature algorithm ssh-rsa not in PubkeyAcceptedAlgorithms".
    services.openssh.extraConfig = lib.mkAfter ''
      Match User scanner
        ChrootDirectory ${scanDir}
        ForceCommand internal-sftp -u 0022 -d /consume
        AllowTcpForwarding no
        X11Forwarding no
        PermitTunnel no
        PermitTTY no
        PubkeyAcceptedAlgorithms +ssh-rsa
    '';

    # SMB fallback. The scanner password is set out-of-band with
    # `smbpasswd -a scanner`, like /var/lib/mosquitto/hass-password.
    services.samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = true; # NetBIOS, so the scanner's "Browse Network" finds us
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "bristlecone";
          "security" = "user";
          "map to guest" = "never";
          "load printers" = "no";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";
        };
        scan = {
          "path" = "${scanDir}/consume";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "scanner";
          "force user" = "paperless"; # uploads land owned by paperless
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    # changedetection.io (website change monitoring)
    services.changedetection-io = {
      enable = true;
      listenAddress = "0.0.0.0";
      behindProxy = true;
      playwrightSupport = true;
    };

    # Karakeep bookmark / read-it-later app
    # meilisearch (127.0.0.1:7700) and headless chromium (127.0.0.1:9222) are
    # enabled by default by the upstream module. MEILI_MASTER_KEY and
    # NEXTAUTH_SECRET are generated by karakeep-init into
    # /var/lib/karakeep/settings.env on first boot — don't declare them here.
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        # Reached over the LAN by hostname, not localhost, so pin the origin
        # instead of letting next-auth infer it from request headers.
        NEXTAUTH_URL = "http://bristlecone:3000";
        DISABLE_NEW_RELEASE_CHECK = "true";

        # AI tagging/summaries go through the local 9router gateway below.
        # Inference only switches on once OPENAI_API_KEY is set; that key is a
        # 9router API key and lives in /var/lib/karakeep/settings.env (append
        # `OPENAI_API_KEY=...` there — karakeep-init never overwrites it).
        OPENAI_BASE_URL = "http://127.0.0.1:20128/v1";
        INFERENCE_TEXT_MODEL = "cx/gpt-5.6-luna";
        INFERENCE_IMAGE_MODEL = "cx/gpt-5.6-luna";
        # 9router drops json_schema response_format, so ask for plain JSON mode.
        INFERENCE_OUTPUT_SCHEMA = "json";
      };
    };

    # 9router AI gateway: one shared instance so provider logins, OAuth
    # refresh and quota tracking live in one place; agents on the other hosts
    # point ANTHROPIC_BASE_URL / OpenAI base URLs at it over netbird.
    #
    # Runs the bundled Next.js server directly rather than the `9router` CLI,
    # which shows an interactive menu, detaches its child and npm-installs
    # sqlite/tray deps into $HOME at startup. The server uses node:sqlite and
    # the sql.js copy bundled in app/node_modules, so nothing is fetched.
    #
    # Dashboard login defaults to "123456" and /v1 needs no API key until one
    # is required in the dashboard — hence netbird-only (see firewall below).
    systemd.services."9router" = {
      description = "9router AI gateway";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        NODE_ENV = "production";
        DATA_DIR = "/var/lib/9router";
        NEXT_CACHE_DIR = "%C/9router";
        NODE_PATH = "${pkgs._9router}/lib/node_modules/9router/app/node_modules";
        HOSTNAME = "0.0.0.0";
        PORT = "20128";
      };
      serviceConfig = hardenedServiceConfig // {
        ExecStart = "${lib.getExe pkgs.unstable.nodejs} --dns-result-order=ipv4first custom-server.js";
        WorkingDirectory = "${pkgs._9router}/lib/node_modules/9router/app";
        DynamicUser = true;
        StateDirectory = "9router";
        StateDirectoryMode = "0700";
        CacheDirectory = "9router";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ 20128 ];

    # 1883 is mosquitto: LAN IoT devices (Livegrid panel) need to reach it.
    # 8080 is the Zigbee2MQTT frontend (pairing, device settings, map).
    networking.firewall.allowedTCPPorts = [ 1883 28981 5000 3000 8080 ];

    # mDNS. Home Assistant's zeroconf listener binds UDP 5353 and receives
    # replies on that same port, so the default deny drops every response and
    # nothing is ever auto-discovered — AirGradient, esphome and cast all rely
    # on it. Outbound queries alone are not enough.
    networking.firewall.allowedUDPPorts = [ 5353 ];

    # ──────────────────────────────────────────────
    # Systemd service hardening
    # ──────────────────────────────────────────────

    systemd.services.jellyfin.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      RestrictNamespaces = false;
      ReadWritePaths = [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/var/log/jellyfin" ];
    });
    systemd.services.jellyfin.environment.JELLYFIN_HttpListenerHost__BindAddresses = "0.0.0.0";
    systemd.tmpfiles.rules = [
      "d /var/log/jellyfin 0750 jellyfin jellyfin -"
      # Chroot root: must be root-owned and not group/world-writable.
      # The consume dir inside it is created by the paperless module.
      "d ${scanDir} 0755 root root -"
      # Parent of the local borg repo; borg creates the repo dir itself.
      "d /var/lib/borg 0700 root root -"
    ] ++ map (tag: "d ${scanDir}/consume/${tag} 0777 - - -") scanTags;

    systemd.services.home-assistant.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      PrivateDevices = false; # May need device access for integrations
      RestrictNamespaces = false;
    });

    systemd.services.n8n.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/n8n" ];
    });

    systemd.services.paperless-web.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
    systemd.services.paperless-scheduler.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
    systemd.services.paperless-consumer.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;

    systemd.services.changedetection-io.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/changedetection-io" ];
    });

    # karakeep-init is left alone (oneshot that must run openssl + migrations),
    # as is karakeep-browser (upstream already sandboxes it more strictly).
    systemd.services.karakeep-web.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      # CacheDirectory now comes from 26.05's karakeep module (it used to be
      # backported here); it is not in hardenedServiceConfig, so the mkForce
      # above leaves upstream's value intact.
      ReadWritePaths = [ "/var/lib/karakeep" ];
    });
    # NEXT_CACHE_DIR still has to be set here. 26.05's karakeep module writes
    # `environment = { NEXT_CACHE_DIR = "%C/karakeep"; } // karakeepEnv;`, but
    # karakeepEnv is a lib.mkMerge value, so `//` yields an attrset carrying
    # `_type = "merge"`; the module system then takes only `contents` and drops
    # NEXT_CACHE_DIR on the floor. Without it Next.js writes its cache next to
    # the read-only store copy of the app, which our ProtectSystem = "strict"
    # makes fatal. Verified absent from the rendered environment on 26.05.
    systemd.services.karakeep-web.environment.NEXT_CACHE_DIR = "%C/karakeep";

    systemd.services.karakeep-workers.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/karakeep" ];
    });
  };
}
