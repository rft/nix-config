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
        settings = lib.mkIf myconfig.services.ai-gateway.enable {
          # The 9router gateway on this host, over loopback. Its key, if the
          # dashboard requires one, is NINEROUTER_API_KEY in the env file.
          providers."9router" = {
            api = "http://127.0.0.1:20128/v1";
            key_env = "NINEROUTER_API_KEY";
          };
          model.provider = "9router";
        };
      };

      # The state dirs are 2770 hermes:hermes, so the shell CLI needs the group.
      users.users.${myconfig.constants.username}.extraGroups = [ "hermes" ];

      # Most of the baseline holds for an agent, but it runs arbitrary tools:
      # a syscall allowlist breaks whatever it installs, and Chromium's sandbox
      # (browser tools) needs user namespaces. ProtectHome is forced on over
      # upstream's false: the agent's HOME is stateDir.
      systemd.services.hermes-agent.serviceConfig = lib.mapAttrs (_: lib.mkForce) (
        removeAttrs hardenedServiceConfig [
          "SystemCallFilter"
          "RestrictNamespaces"
        ]
      );

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
        exclude_patterns = [ "${stateDir}/.hermes/state.db*" ];
      };
    };
}
