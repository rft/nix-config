{
  delib,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.hermes-agent";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.hermes-agent.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.always.imports = [ inputs.hermes-agent.nixosModules.default ];

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      stateDir = "/var/lib/hermes";
      # The login user's repos. Declared in hosts/bristlecone/default.nix,
      # which also gives the directory its exec bind mount.
      projectsDir = "/srv/projects";
    in
    {
      # Hermes Agent messaging gateway (Telegram, Discord, Slack, ...) plus its
      # cron scheduler. It only dials out, so no firewall ports.
      services.hermes-agent = {
        enable = true;
        inherit stateDir;
        # core puts llm-agents' hermes on every host; here the CLI must be the
        # same build as the service, since both open one HERMES_HOME.
        package = lib.hiPrio inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # `hermes` in a shell shares the gateway's sessions, skills and cron
        # instead of starting a separate ~/.hermes.
        addToSystemPackages = true;
        # Provider keys and bot tokens, written by hand (see docs/SERVICES.md).
        # Activation merges this into $HERMES_HOME/.env, so edits take effect
        # on the next switch.
        environmentFiles = [ "${stateDir}/env" ];
        settings = lib.mkMerge [
          {
            # The OpenAI-compatible API server platform (port 8642, below) has
            # no /approve channel, so an approval prompt raised there has nobody
            # to answer it: `unattended_mode` decides instead of the prompt.
            # Kept at upstream's `deny` deliberately — `mode = "smart"` still
            # lets an aux LLM wave through low-risk commands, so the assistant
            # stays useful, while genuinely dangerous ones are refused and the
            # agent routes around them rather than running unsupervised. That
            # matters more now that the agent can write to ${projectsDir}: set
            # this to "approve" only if you want a voice channel with no
            # confirmation step to be able to run destructive commands there.
            approvals.unattended_mode = "deny";

            # Telegram, the one channel that can answer an approval prompt
            # (/approve) and that has no 25s client timeout or ~500-character
            # display to fight. Unlike the API server there is no
            # TELEGRAM_ENABLED env var to flip — upstream's PlatformConfig
            # defaults `enabled` to false and only whatsapp, webhook and
            # api_server read an *_ENABLED variable — so the switch has to live
            # in config.yaml, which is what this block renders. The bot token
            # stays out of Nix: TELEGRAM_BOT_TOKEN and TELEGRAM_ALLOWED_USERS
            # go in ${stateDir}/env (see docs/SERVICES.md). With the platform
            # on and no token, the gateway logs an empty-token warning and
            # carries on rather than failing to start.
            platforms.telegram.enabled = true;
          }
          (lib.mkIf myconfig.services.ai-gateway.enable {
            # The 9router gateway on this host. Its dashboard has API-key auth
            # turned on, so NINEROUTER_API_KEY in the env file is required —
            # loopback is not exempt. Without it every inference call comes back
            # "Missing API key" (/v1/models stays open either way).
            providers."9router" = {
              api = "http://127.0.0.1:20128/v1";
              key_env = "NINEROUTER_API_KEY";
            };
            model = {
              provider = "9router";
              default = "cx/gpt-6.1-sol";
            };
            # An interactive `hermes chat` blocks on a full-screen shared-metrics
            # consent prompt until the profile has answered, and a prompt nobody
            # can answer looks like a hang when the agent is reached over sudo.
            # Answer it here instead. `offer_version` is upstream's OFFER_VERSION
            # (hermes_cli/observability/shared_metrics_consent.py): an explicit
            # "off" without it reads as never-seen and is asked again. The gateway
            # itself never asks, so this only affects shells. Flip `enabled` and
            # `send` to true to opt in.
            telemetry.shared_metrics = {
              enabled = false;
              send = false;
              offer_version = 2;
            };
          })
          (lib.mkIf myconfig.services.home-assistant.enable {
            # Plugins are opt-in; the manifest name is what this list matches.
            plugins.enabled = [ "homeassistant" ];
            # Home Assistant left Hermes core for a catalog plugin, and a profile
            # with HASS_TOKEN that lacks `$HERMES_HOME/plugins/homeassistant`
            # gets a "moved out of core … this profile does not have" warning on
            # every start (backed off hourly up to weekly). extraPlugins links
            # the plugin as `nix-managed-homeassistant`, which that exact-path
            # check misses, so mark the migration done
            # (hermes_cli/left_core_migration.py, `_left_core_installed`).
            _left_core_installed = [ "homeassistant" ];
          })
        ];

        # Home Assistant tools (ha_list_entities, ha_get_state,
        # ha_list_services, ha_call_service) plus the gateway platform that
        # turns HA state changes into agent messages and agent replies into HA
        # persistent notifications. The plugin's only Python dependency,
        # aiohttp, is already in the package's venv. HASS_TOKEN (a long-lived
        # access token) goes in the env file; see docs/SERVICES.md.
        #
        # No `platforms.homeassistant.extra.watch_*` filters, so no state change
        # wakes the agent: each forwarded event is a model call. The tools, cron
        # `deliver: homeassistant:<notify target>` and notifications work
        # without them.
        extraPlugins = lib.mkIf myconfig.services.home-assistant.enable [
          (pkgs.runCommandLocal "homeassistant" { } ''
            cp -r ${inputs.hermes-official-plugins}/homeassistant $out
          '')
        ];
        # Non-secret, so not in the env file. The tools read only HASS_URL
        # (the platform's `extra.url` does not reach them). Same host, so
        # loopback.
        environment = lib.mkIf myconfig.services.home-assistant.enable {
          HASS_URL = "http://127.0.0.1:8123";
        };
      };

      # The OpenAI-compatible API server platform, for clients that are not a
      # messaging app — an Even Realities G2 pointed at
      # `http://bristlecone.netbird.cloud:8642/v1/chat/completions`, Open WebUI,
      # or another Hermes host via `hermes peer`. The agent keeps its own loop
      # here (memory, skills, sessions), unlike the codex_app_server runtime,
      # where codex owns the loop and Hermes is reduced to an MCP tool box.
      #
      # NetBird-only, like the other web UIs on this host. Nothing listens until
      # API_SERVER_ENABLED and a usable API_SERVER_KEY (>= 16 chars) are in the
      # env file; the platform refuses to start without the key, loopback
      # included. See docs/SERVICES.md for the full env block.
      networking.firewall.interfaces.wt0.allowedTCPPorts = [ 8642 ];

      # Deliberately no `hermes` group for the login user. Upstream's tmpfiles
      # rules force 2770 on stateDir and HERMES_HOME, and the CLI's
      # gateway_runtime_discovery refuses the gateway control path twice over:
      # the caller's uid must own HERMES_HOME (`expected_uid = os.getuid()`),
      # and home_mode_unsafe rejects a group-writable home whose group has any
      # member besides the owner. Adding the user to the group therefore blocks
      # `hermes chat` for everyone while buying only file-level reads. Reach the
      # shared agent as its owner instead:
      #   sudo -u hermes -H hermes chat
      # (-H sets HOME=/var/lib/hermes, so HERMES_HOME resolves on its own.)

      # Most of the baseline holds for an agent, but it runs arbitrary tools:
      # a syscall allowlist breaks whatever it installs, and Chromium's sandbox
      # (browser tools) needs user namespaces. ProtectHome is forced on over
      # upstream's false: the agent's HOME is stateDir.
      systemd.services.hermes-agent.serviceConfig =
        lib.mapAttrs (_: lib.mkForce) (
          removeAttrs hardenedServiceConfig [
            "SystemCallFilter"
            "RestrictNamespaces"
          ]
        )
        // {
          # ProtectSystem=strict leaves the whole hierarchy read-only apart
          # from this list, so without the entry the agent could read the repos
          # but not build or test in them. Merges with upstream's stateDir
          # entries rather than replacing them (systemd unit options
          # concatenate lists).
          ReadWritePaths = [ projectsDir ];
        };

      # git refuses to parse a repository owned by another user ("detected
      # dubious ownership"), which would stop the agent at the first `git
      # status` in the login user's repos. git only honours safe.directory
      # from a protected scope, so it cannot go in the agent's own
      # ~/.gitconfig; GIT_CONFIG_SYSTEM is the system scope, pointed at a file
      # that includes nix-mineral's hardened /etc/gitconfig rather than
      # replacing it (`programs.git.config` would collide with that file, and
      # copying its contents here would silently go stale). Scoped to this
      # service, so other users keep the stock config. The `/*` suffix covers
      # every repo under the tree without the global `safe.directory = "*"`
      # opt-out.
      systemd.services.hermes-agent.environment.GIT_CONFIG_SYSTEM = pkgs.writeText "hermes-gitconfig" ''
        [include]
        	path = /etc/gitconfig
        [safe]
        	directory = ${projectsDir}/*
      '';

      # Reaching the repos takes a filesystem grant as well as the sandbox one:
      # the tree is 0755 `username`:users and the agent is neither. A named ACL
      # entry for the `hermes` group is what crosses that, and `A+` is recursive
      # and additive, so the project directories that already exist are covered
      # without rewriting their modes — a recursive chmod would have to set the
      # setgid bit on regular files to grant the same thing. The `d:` entry is
      # the default ACL, so repos cloned later inherit the grant.
      #
      # This is a broad grant: the agent runs whatever tools it installs, and
      # it now does so with write access to every repo on the host.
      systemd.tmpfiles.rules = [
        "A+ ${projectsDir} - - - - d:group:hermes:rwx,group:hermes:rwx"
      ];

      # nix-mineral mounts /var noexec. The agent installs tools into its HOME
      # (pip --user, uv tool, npm -g) and runs scripts in its workspace, all
      # under stateDir. Upstream's tmpfiles rules give the bind-mount target
      # back to hermes:hermes.
      nix-mineral.filesystems.normal.${stateDir} = {
        enable = true;
        options = {
          noexec = false;
          exec = true;
        };
      };

      # Sessions live in state.db (WAL), so it is dumped rather than copied
      # raw; config, memories, skills and the workspace are plain files.
      services.borgmatic.settings = {
        source_directories = [ stateDir ];
        sqlite_databases = [
          {
            name = "hermes";
            path = "${stateDir}/.hermes/state.db";
          }
        ];
        # response_store.db is the /v1/responses chaining cache the API server
        # platform writes. Excluded rather than dumped: it only exists once that
        # platform is switched on, and borgmatic's sqlite hook fails on a path
        # that is not there, which would take the whole backup down on every
        # host that leaves the API server off. Nothing needs restoring from it.
        exclude_patterns = [
          "${stateDir}/.hermes/state.db*"
          "${stateDir}/.hermes/response_store.db*"
        ];
      };
    };
}
