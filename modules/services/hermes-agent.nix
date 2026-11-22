{
  delib,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;

  # One directory of Nous Research's official plugin repo, as an extraPlugins
  # entry. extraPlugins links each as `plugins/nix-managed-<name>`.
  officialPlugin =
    name:
    pkgs.runCommandLocal name { } ''
      cp -r ${inputs.hermes-official-plugins}/${name} $out
    '';
in
delib.module {
  name = "services.hermes-agent";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.hermes-agent.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.always.imports = [
    inputs.hermes-agent.nixosModules.default

    # actual-mcp drives Actual through @actual-app/api, which migrates the
    # budget file to its own version. Newer than the server, and the web client
    # the server ships can no longer open the budget. Denix blocks don't see the
    # NixOS `config`, hence a plain module.
    (
      { config, ... }:
      {
        assertions = [
          {
            assertion =
              !(config.services.hermes-agent.enable && config.services.actual.enable)
              || pkgs.actual-mcp.actualApiVersion == config.services.actual.package.version;
            message = ''
              services.hermes-agent: actual-mcp ${pkgs.actual-mcp.version} is built against
              @actual-app/api ${pkgs.actual-mcp.actualApiVersion}, but the Actual server is
              ${config.services.actual.package.version}. Bump packages/actual-mcp to the release that
              pins @actual-app/api ${config.services.actual.package.version} (see its version history
              on npm) before deploying.
            '';
          }
        ];
      }
    )
  ];

  nixos.ifEnabled =
    { myconfig, ... }:
    let
      stateDir = "/var/lib/hermes";
      # The login user's repos. Declared in hosts/bristlecone/default.nix,
      # which also gives the directory its exec bind mount.
      projectsDir = "/srv/projects";
      # The general SMB share, also from hosts/bristlecone/default.nix. The
      # agent gets read-only access: a drop folder for files to ask about.
      shareDir = "/srv/share";
      # Actual's self-signed TLS cert, published world-readable by
      # services.actual so clients on this host can trust it.
      actualCert = "/var/lib/actual-cert/cert.pem";

      fqdn = "${myconfig.host.name}.netbird.cloud";
      svc = myconfig.services;

      # Upstream's flake never passes `version`, so a build of `main` stamps
      # the placeholder "0.0.0" as its release, and "0.0.0" fails every
      # plugin's `requires_hermes` floor: the plugin is skipped at load
      # ("requires hermes >=0.21.5, running 0.0.0"), every catalog plugin here
      # included. An unparseable version passes the gate instead
      # (version_satisfies), which is what upstream's fix does for a tagless
      # pin: NousResearch/hermes-agent#146654, for issues #144616/#150066.
      # Drop this override once that is merged.
      hermesPackage = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        version = "unknown";
      };
      # extraPythonPackages must be built with Hermes' own interpreter (3.14).
      pyPkgs = hermesPackage.python.pkgs;

      # The langfuse plugin pins langfuse==4.15.2; nixpkgs has 4.0.2, which
      # builds with poetry-core where 4.15 uses uv_build.
      #
      # Built without its dependencies: upstream's module refuses any
      # extraPythonPackages closure that repeats a package of the sealed venv,
      # and the venv already has httpx, pydantic, wrapt, packaging and the
      # OpenTelemetry SDK/exporter (pinned by upstream's lock). backoff is the
      # one runtime dependency it lacks, so it rides along on its own. The
      # runtime-deps and import checks would look for the rest in the build
      # environment, where they deliberately are not.
      langfuse = pyPkgs.langfuse.overridePythonAttrs (_: rec {
        version = "4.15.2";
        src = pkgs.fetchFromGitHub {
          owner = "langfuse";
          repo = "langfuse-python";
          tag = "v${version}";
          hash = "sha256-TSiirJ9wA5TX8f+v/5hLp/TuHVseVhFVZNaaZqmPkcc=";
        };
        build-system = [ pyPkgs.uv-build ];
        # Upstream caps uv_build below 0.12; nixpkgs ships 0.12.x.
        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail '"uv_build>=0.11.2,<0.12.0"' '"uv_build>=0.11.2"'
        '';
        dependencies = [ ];
        dontCheckRuntimeDeps = true;
        pythonImportsCheck = [ ];
      });

      # `hermes mcp-serve` for MCP clients on other machines, which reach it
      # over SSH (`ssh bristlecone hermes-mcp-serve`). It has to run as the
      # agent's own user (same HERMES_HOME as the gateway), and sudo cannot
      # prompt over a non-interactive SSH session, so the sudo rule below lets
      # the login user run exactly these two command lines without a password.
      # The system profile's hermes, not ${hermesPackage}: with
      # extraPythonPackages set, upstream builds and installs an overridden
      # package (the one the units run), and only that one has langfuse.
      # Matching the sudo rule on this root-owned path keeps them the same
      # build without reaching into upstream's internals.
      hermesBin = "/run/current-system/sw/bin/hermes";
      hermesMcpServe = pkgs.writeShellScriptBin "hermes-mcp-serve" ''
        exec /run/wrappers/bin/sudo -n -u hermes -H ${hermesBin} mcp-serve "$@"
      '';

      # Applied to the gateway and to the dashboard backend alike: both run
      # agent turns (the dashboard has an embedded chat), so both need the same
      # sandbox, repo access and git config.
      #
      # Most of the baseline holds for an agent, but it runs arbitrary tools:
      # a syscall allowlist breaks whatever it installs, and bubblewrap (the
      # terminal backend, below) and Chromium's sandbox (browser tools) need
      # user namespaces. ProtectHome is forced on over upstream's false: the
      # agent's HOME is stateDir.
      #
      # ProtectKernelTunables and ProtectKernelLogs are off for bubblewrap: they
      # overmount /proc/sys and /proc/kmsg, and the kernel refuses a fresh
      # procfs mount inside a user namespace while such locked overmounts would
      # be revealed by it ("bwrap: Can't mount proc on /proc: Operation not
      # permitted"). Little is lost: the agent is not root, so /proc/sys stays
      # read-only and /proc/kmsg unreadable to it anyway.
      agentServiceConfig =
        lib.mapAttrs (_: lib.mkForce) (
          removeAttrs hardenedServiceConfig [
            "SystemCallFilter"
            "RestrictNamespaces"
            "ProtectKernelTunables"
            "ProtectKernelLogs"
          ]
        )
        // {
          # ProtectSystem=strict leaves the whole hierarchy read-only apart
          # from this list, so without the entry the agent could read the repos
          # but not build or test in them. Merges with upstream's stateDir
          # entries rather than replacing them (systemd unit options
          # concatenate lists).
          ReadWritePaths = [ projectsDir ];
          # bubblewrap's per-command memory limit is RLIMIT_AS (address space),
          # which breaks node, the JVM and most compilers long before they use
          # real memory, so it is turned off below. A cgroup cap on the whole
          # unit takes its place.
          MemoryMax = "24G";
        };

      # git refuses to parse a repository owned by another user ("detected
      # dubious ownership"), which would stop the agent at the first `git
      # status` in the login user's repos. git only honours safe.directory
      # from a protected scope, so it cannot go in the agent's own
      # ~/.gitconfig; GIT_CONFIG_SYSTEM is the system scope, pointed at a file
      # that includes nix-mineral's hardened /etc/gitconfig rather than
      # replacing it (`programs.git.config` would collide with that file, and
      # copying its contents here would silently go stale). Scoped to these
      # services, so other users keep the stock config. The `/*` suffix covers
      # every repo under the tree without the global `safe.directory = "*"`
      # opt-out.
      agentGitConfig = pkgs.writeText "hermes-gitconfig" ''
        [include]
        	path = /etc/gitconfig
        [safe]
        	directory = ${projectsDir}/*
      '';
    in
    {
      # Hermes Agent messaging gateway (Telegram, Discord, Slack, ...) plus its
      # cron scheduler. It only dials out, so no firewall ports.
      services.hermes-agent = {
        enable = true;
        inherit stateDir;
        # core puts llm-agents' hermes on every host; here the CLI must be the
        # same build as the service, since both open one HERMES_HOME.
        package = lib.hiPrio hermesPackage;
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

            # Plugins are opt-in; the manifest name is what this list matches.
            # Each one is linked in by extraPlugins below. One list, not one
            # per mkIf: `settings` merges with recursiveUpdate, under which a
            # later list replaces an earlier one instead of extending it.
            plugins.enabled = [
              "bubblewrap"
              "homelab"
              "langfuse"
              "mcp-serve"
              "memory-wiki"
            ]
            ++ lib.optional svc.home-assistant.enable "homeassistant";

            # Every terminal and execute_code command runs in its own bwrap
            # sandbox: the host root read-only at the same paths, a writable
            # working directory, dot entries of HOME and all of HERMES_HOME
            # (.env, auth.json, state.db) hidden, private /tmp and /proc. The
            # approval rules apply on top, unchanged.
            terminal.backend = "bubblewrap";
            plugins.entries.bubblewrap.settings = {
              # `network` shares the host network: the agent clones, installs
              # and fetches. `workspace` would cut it off.
              profile = "network";
              binds = [
                {
                  src = projectsDir;
                  readonly = false;
                }
                { src = shareDir; }
              ];
              # RLIMIT_AS / RLIMIT_CPU per command: the defaults (256 MB, 30 s)
              # stop pip, node and any real build. MemoryMax on the unit caps
              # memory instead, and terminal.timeout caps wall time.
              memory_mb = 0;
              cpu_seconds = 0;
              # Counted per sandbox; parallel builds spawn many threads.
              max_procs = 2048;
            };

            # Home Assistant, Langfuse and Spotify moved out of Hermes core into
            # catalog plugins, and the migration that moved them checks for
            # exactly `plugins/<name>`. extraPlugins links them as
            # `nix-managed-<name>`, which that check misses: it would warn on
            # every start (backed off hourly up to weekly) and try to install a
            # second copy from the catalog. Mark the migration done
            # (hermes_cli/left_core_migration.py, `_left_core_installed`).
            # mcp-serve also left core but is never detected as in use.
            _left_core_installed = [
              "langfuse"
            ]
            ++ lib.optional svc.home-assistant.enable "homeassistant";
          }
          (lib.mkIf svc.ai-gateway.enable {
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
        ];

        extraPlugins = [
          (officialPlugin "bubblewrap")
          # One trace per turn, LLM call and tool call, to Langfuse Cloud or a
          # self-hosted instance. Fails open: without HERMES_LANGFUSE_* keys in
          # the env file it logs one warning and does nothing.
          (officialPlugin "langfuse")
          # `hermes mcp-serve`: Hermes' conversations (and, with --tools, its
          # web/vision/skills tools) for MCP clients; see hermesMcpServe above.
          (officialPlugin "mcp-serve")
          # A Memory Wiki tab in the dashboard (backend.mode below): subject
          # pages and daily logs derived from state.db, plus a read-only view
          # of MEMORY.md / USER.md. No LLM calls, no writes.
          (officialPlugin "memory-wiki")
          # This repo's tools for Paperless, Karakeep, changedetection and a
          # server health check (packages/hermes-homelab). Each service's
          # tools show up once its token is in the env file.
          (pkgs.callPackage ../../packages/hermes-homelab { })
        ]
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
        ++ lib.optional svc.home-assistant.enable (officialPlugin "homeassistant");

        # bwrap for the bubblewrap backend; prlimit (util-linux) applies its
        # limits.
        extraPackages = [
          pkgs.bubblewrap
          pkgs.util-linux
        ];
        # mcp, which mcp-serve needs, is already in the venv; langfuse is not.
        extraPythonPackages = [
          langfuse
          pyPkgs.backoff
        ];

        # Non-secret, so not in the env file.
        environment = lib.mkMerge [
          {
            # Structure, token counts, cost and timing only: no prompt,
            # response or tool content leaves the host. The agent handles
            # documents, budgets and home state, and `sanitized` (upstream's
            # default) is pattern-based redaction, not a guarantee. Set
            # HERMES_LANGFUSE_CAPTURE=sanitized in the env file to override.
            HERMES_LANGFUSE_CAPTURE = "metadata";
          }
          (lib.mkIf svc.home-assistant.enable {
            # The HA tools read only HASS_URL (the platform's `extra.url` does
            # not reach them). Same host, so loopback.
            HASS_URL = "http://127.0.0.1:8123";
          })
        ];

        # Actual Budget has no REST API, only the @actual-app/api library,
        # which downloads the budget into ACTUAL_DATA_DIR and works on that
        # copy. actual-mcp wraps it; without --enable-write it registers only
        # read tools (transactions, spending by category, monthly summary,
        # balances, accounts, categories, payees, rules). `${VAR}` entries are
        # filled from the env file at spawn time; an unset one is dropped.
        #
        # Through the NetBird name rather than loopback: Actual's self-signed
        # cert is issued for that name only, and NODE_EXTRA_CA_CERTS trusts it.
        mcpServers = lib.mkIf svc.actual.enable {
          actual = {
            command = lib.getExe pkgs.actual-mcp;
            env = {
              ACTUAL_SERVER_URL = "https://${fqdn}:5006";
              ACTUAL_DATA_DIR = "${stateDir}/actual-mcp";
              NODE_EXTRA_CA_CERTS = actualCert;
              ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
              ACTUAL_BUDGET_SYNC_ID = "\${ACTUAL_BUDGET_SYNC_ID}";
              ACTUAL_BUDGET_ENCRYPTION_PASSWORD = "\${ACTUAL_BUDGET_ENCRYPTION_PASSWORD}";
            };
          };
        };

        # The web dashboard (and the backend Hermes Desktop connects to), for
        # the Memory Wiki tab. A separate unit, hermes-backend, on the same
        # HERMES_HOME. Bound to the NetBird name: a non-loopback bind turns on
        # the dashboard's auth gate, and the server rejects any Host header
        # other than the name it bound to, so open it as
        # http://bristlecone.netbird.cloud:9119. Credentials
        # (HERMES_DASHBOARD_BASIC_AUTH_*) go in the env file; without them
        # nobody can sign in. Signed in, the dashboard can edit config and open
        # a terminal as the agent, so treat that password like SSH access.
        backend = {
          mode = "dashboard";
          host = fqdn;
          # NetBird's DNS may come up after this unit at boot.
          waitFor = "hostname";
          port = 9119;
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
      #
      # 9119 is the dashboard (backend above).
      networking.firewall.interfaces.wt0.allowedTCPPorts = [
        8642
        9119
      ];

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

      systemd.services.hermes-agent = {
        serviceConfig = agentServiceConfig;
        environment.GIT_CONFIG_SYSTEM = agentGitConfig;
        # actual-mcp starts with the gateway and needs Actual's cert (copied
        # out when Actual starts) and server.
        after = lib.optional svc.actual.enable "actual.service";
      };
      systemd.services.hermes-backend = {
        serviceConfig = agentServiceConfig;
        environment.GIT_CONFIG_SYSTEM = agentGitConfig;
      };

      environment.systemPackages = [ hermesMcpServe ];
      security.sudo.extraRules = [
        {
          users = [ myconfig.constants.username ];
          runAs = "hermes";
          commands = [
            {
              command = "${hermesBin} mcp-serve";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${hermesBin} mcp-serve --tools";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

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
      #
      # The share gets read only (r-X: files readable, directories
      # traversable). Samba's create mask (0644) would clamp a write grant to
      # read on every file dropped in over SMB anyway.
      systemd.tmpfiles.rules = [
        "A+ ${projectsDir} - - - - d:group:hermes:rwx,group:hermes:rwx"
        "A+ ${shareDir} - - - - d:group:hermes:r-X,group:hermes:r-X"
      ]
      ++ lib.optional svc.actual.enable "d ${stateDir}/actual-mcp 0700 hermes hermes -";

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
        # actual-mcp's directory is a downloaded copy of the budget, which
        # Actual's own backup already covers.
        exclude_patterns = [
          "${stateDir}/.hermes/state.db*"
          "${stateDir}/.hermes/response_store.db*"
          "${stateDir}/actual-mcp"
        ];
      };
    };
}
