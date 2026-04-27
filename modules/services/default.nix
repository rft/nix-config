{ delib, pkgs, lib, ... }:
let
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
      borgmatic
    ];

    # Jellyfin media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Mosquitto MQTT broker
    services.mosquitto = {
      enable = true;
      listeners = [{
        acl = [ "pattern readwrite #" ];
        users.hass = {
          acl = [ "readwrite #" ];
          hashedPasswordFile = "/var/lib/mosquitto/hass-password";
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
      ];
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "America/Phoenix";
        };
        default_config = {};
      };
    };

    # n8n workflow automation
    services.n8n = {
      enable = true;
      openFirewall = true;
      environment.N8N_SECURE_COOKIE = "false";
    };

    # Paperless document management
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
    };

    # Kasm Workspaces (container-based browser/desktop streaming)
    # Requires Docker (upstream module hardcodes docker backend)
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = {
      dns = [ "8.8.8.8" "1.1.1.1" ];
    };
    services.kasmweb = {
      enable = true;
      listenPort = 8443;
    };

    # changedetection.io (website change monitoring)
    services.changedetection-io = {
      enable = true;
      listenAddress = "0.0.0.0";
      behindProxy = true;
      playwrightSupport = true;
    };

    networking.firewall.allowedTCPPorts = [ 28981 8443 5000 ];

    # ──────────────────────────────────────────────
    # Systemd service hardening
    # ──────────────────────────────────────────────

    systemd.services.jellyfin.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      RestrictNamespaces = false;
      ReadWritePaths = [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/var/log/jellyfin" ];
    });
    systemd.services.jellyfin.environment.JELLYFIN_HttpListenerHost__BindAddresses = "0.0.0.0";
    systemd.tmpfiles.rules = [ "d /var/log/jellyfin 0750 jellyfin jellyfin -" ];

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

    # Fix upstream kasmweb init bugs:
    # 1. Missing hostname, systemctl, coreutils in PATH
    # 2. ln -sf to /nix/store paths breaks inside Docker containers —
    #    containers can't follow host symlinks into the store.
    #    Override ExecStart to use cp -rL (copy, dereference) instead.
    systemd.services.init-kasmweb.path = [ pkgs.inetutils pkgs.systemd pkgs.coreutils ];
    systemd.services.init-kasmweb.serviceConfig.ExecStart = let
      kasmDataDir = "/var/lib/kasmweb";
      kasmPkg = pkgs.kasmweb;
      cfg = {
        datastorePath = kasmDataDir;
        networkSubnet = "172.20.0.0/16";
        sslCertificate = "null";
        sslCertificateKey = "null";
        redisPassword = "kasmweb";
        defaultUserPassword = "kasmweb";
        defaultAdminPassword = "kasmweb";
        defaultManagerToken = "kasmweb";
        defaultRegistrationToken = "kasmweb";
        defaultGuacToken = "kasmweb";
      };
    in lib.mkForce (toString (pkgs.writeScript "initialize-kasmweb-patched" ''
      #!${pkgs.runtimeShell}
      export PATH=${lib.makeBinPath [ pkgs.docker pkgs.openssl pkgs.gnused pkgs.yq-go pkgs.inetutils pkgs.systemd pkgs.coreutils ]}:$PATH

      mkdir -p ${kasmDataDir}/log
      chmod -R a+rw ${kasmDataDir}

      # Copy instead of symlink so Docker containers can access the files
      rm -rf ${kasmDataDir}/bin
      cp -rL ${kasmPkg}/bin ${kasmDataDir}/bin
      chmod -R a+rw ${kasmDataDir}/bin

      rm -rf ${kasmDataDir}/conf
      cp -r ${kasmPkg}/conf ${kasmDataDir}/conf
      mkdir -p ${kasmDataDir}/conf/nginx/containers.d
      chmod -R a+rw ${kasmDataDir}/conf

      rm -rf ${kasmDataDir}/www
      cp -rL ${kasmPkg}/www ${kasmDataDir}/www
      chmod -R a+rw ${kasmDataDir}/www

      cat >${kasmDataDir}/init_seeds.sh <<SEEDEOF
      #!/bin/bash
      if [ ! -e /opt/kasm/current/.done_initing_data ]; then
        while true; do
            sleep 15;
            /usr/bin/kasm_server.so --initialize-database --cfg \
              /opt/kasm/current/conf/app/api.app.config.yaml \
              --seed-file \
              /opt/kasm/current/conf/database/seed_data/default_properties.yaml \
              --populate-production \
              && break
        done  && /usr/bin/kasm_server.so --cfg \
          /opt/kasm/current/conf/app/api.app.config.yaml \
          --populate-production \
          --seed-file \
          /opt/kasm/current/conf/database/seed_data/default_agents.yaml \
        && /usr/bin/kasm_server.so --cfg \
          /opt/kasm/current/conf/app/api.app.config.yaml \
          --populate-production \
          --seed-file \
          /opt/kasm/current/conf/database/seed_data/default_images_amd64.yaml \
        && touch /opt/kasm/current/.done_initing_data

        while true; do sleep 10 ; done
      else
       echo "skipping database init"
        while true; do sleep 10 ; done
      fi
      SEEDEOF

      docker network inspect kasm_default_network >/dev/null 2>&1 || docker network create kasm_default_network --subnet ${cfg.networkSubnet}
      if [ -e ${kasmDataDir}/ids.env ]; then
          source ${kasmDataDir}/ids.env
      else
          API_SERVER_ID=$(cat /proc/sys/kernel/random/uuid)
          MANAGER_ID=$(cat /proc/sys/kernel/random/uuid)
          SHARE_ID=$(cat /proc/sys/kernel/random/uuid)
          SERVER_ID=$(cat /proc/sys/kernel/random/uuid)
          echo "export API_SERVER_ID=$API_SERVER_ID" > ${kasmDataDir}/ids.env
          echo "export MANAGER_ID=$MANAGER_ID" >> ${kasmDataDir}/ids.env
          echo "export SHARE_ID=$SHARE_ID" >> ${kasmDataDir}/ids.env
          echo "export SERVER_ID=$SERVER_ID" >> ${kasmDataDir}/ids.env

          mkdir -p ${kasmDataDir}/certs
          openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout ${kasmDataDir}/certs/kasm_nginx.key -out ${kasmDataDir}/certs/kasm_nginx.crt -subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=$(hostname)/emailAddress=none@none.none" 2> /dev/null

          mkdir -p ${kasmDataDir}/file_mappings

          docker volume create kasmweb_db || true
          rm -f ${kasmDataDir}/.done_initing_data
      fi

      chmod +x ${kasmDataDir}/init_seeds.sh
      chmod a+w ${kasmDataDir}/init_seeds.sh

      if [ -e ${cfg.sslCertificate} ]; then
          cp ${cfg.sslCertificate} ${kasmDataDir}/certs/kasm_nginx.crt
          cp ${cfg.sslCertificateKey} ${kasmDataDir}/certs/kasm_nginx.key
      fi

      # Ensure certs are valid files — a failed prior init can leave them as
      # directories (cp -rL of nix-store symlinks), which crashes nginx.
      if [ ! -f ${kasmDataDir}/certs/kasm_nginx.crt ] || [ ! -f ${kasmDataDir}/certs/kasm_nginx.key ]; then
          rm -rf ${kasmDataDir}/certs/kasm_nginx.crt ${kasmDataDir}/certs/kasm_nginx.key
          mkdir -p ${kasmDataDir}/certs
          openssl req -x509 -nodes -days 1825 -newkey rsa:2048 \
              -keyout ${kasmDataDir}/certs/kasm_nginx.key \
              -out ${kasmDataDir}/certs/kasm_nginx.crt \
              -subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=$(hostname)/emailAddress=none@none.none" 2>/dev/null
      fi

      yq -i '.server.zone_name = "'default'"' ${kasmDataDir}/conf/app/api.app.config.yaml
      yq -i '(.zones.[0]) .zone_name = "'default'"' ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      sed -i -e "s/username.*/username: postgres/g" \
          -e "s/password.*/password: postgres/g" \
          -e "s/host.*db/host: kasm_db/g" \
          -e "s/ssl: true/ssl: false/g" \
          -e "s/redis_password.*/redis_password: ${cfg.redisPassword}/g" \
          -e "s/server_hostname.*/server_hostname: kasm_api/g" \
          -e "s/server_id.*/server_id: $API_SERVER_ID/g" \
          -e "s/manager_id.*/manager_id: $MANAGER_ID/g" \
          -e "s/share_id.*/share_id: $SHARE_ID/g" \
          ${kasmDataDir}/conf/app/api.app.config.yaml

      sed -i -e "s/ token:.*/ token: \"${cfg.defaultManagerToken}\"/g" \
          -e "s/hostnames: \['proxy.*/hostnames: \['kasm_proxy'\]/g" \
          -e "s/server_id.*/server_id: $SERVER_ID/g" \
          ${kasmDataDir}/conf/app/agent.app.config.yaml

      # Generate password hashes
      ADMIN_SALT=$(cat /proc/sys/kernel/random/uuid)
      ADMIN_HASH=$(printf "${cfg.defaultAdminPassword}''${ADMIN_SALT}" | sha256sum | cut -c-64)
      USER_SALT=$(cat /proc/sys/kernel/random/uuid)
      USER_HASH=$(printf "${cfg.defaultUserPassword}''${USER_SALT}" | sha256sum | cut -c-64)

      yq -i  '(.users.[] | select(.username=="admin@kasm.local") | .salt) = "'"''${ADMIN_SALT}"'"'  ${kasmDataDir}/conf/database/seed_data/default_properties.yaml
      yq -i  '(.users.[] | select(.username=="admin@kasm.local") | .pw_hash) = "'"''${ADMIN_HASH}"'"'  ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      yq -i  '(.users.[] | select(.username=="user@kasm.local") | .salt) = "'"''${USER_SALT}"'"'  ${kasmDataDir}/conf/database/seed_data/default_properties.yaml
      yq -i  '(.users.[] | select(.username=="user@kasm.local") | .pw_hash) = "'"''${USER_HASH}"'"'  ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      yq -i   '(.settings.[] | select(.name=="token") | select(.category == "manager")) .value = "'"${cfg.defaultManagerToken}"'"'   ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      yq -i   '(.settings.[] | select(.name=="registration_token") | select(.category == "auth")) .value = "'"${cfg.defaultRegistrationToken}"'"'   ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      sed -i -e "s/upstream_auth_address:.*/upstream_auth_address: 'proxy'/g" \
          ${kasmDataDir}/conf/database/seed_data/default_properties.yaml

      sed -i -e "s/GUACTOKEN/${cfg.defaultGuacToken}/g" \
          -e "s/APIHOSTNAME/proxy/g" \
          ${kasmDataDir}/conf/app/kasmguac.app.config.yaml

      sed -i "s/00000000-0000-0000-0000-000000000000/$SERVER_ID/g" \
          ${kasmDataDir}/conf/database/seed_data/default_agents.yaml

      while [ ! -e ${kasmDataDir}/.done_initing_data ]; do
          sleep 10;
      done

      systemctl restart docker-kasm_proxy.service
    ''));

    systemd.services.changedetection-io.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/changedetection-io" ];
    });
  };
}
