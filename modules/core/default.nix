{
  delib,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  # On every host, servers and the installer ISO included. Tools that only
  # make sense on a machine someone sits at go in core.workstation instead.
  sharedPackages = with pkgs; [
    atuin
    bandwhich
    bat
    bottom
    claude-code
    codex
    difftastic
    dua
    fd
    fzf
    gh
    herdr
    hermes-agent
    git
    inputs.nixcats-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    jujutsu
    lazygit
    netbird
    nmap
    oh-my-pi
    procs
    rclone
    ripgrep
    rsync
    tcpdump
    tealdeer
    trippy
    watchexec
    wget
    yazi
    yq
    zellij
    zoxide
  ];

  linuxOnlyPackages = with pkgs; [
    podman
    podman-tui
  ];
in
delib.module {
  name = "core";

  home.always = { myconfig, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

    # oh-my-pi custom provider: the shared 9router gateway on bristlecone
    # (modules/services/ai-gateway.nix), loopback there and over netbird
    # everywhere else. Discovery reads <baseUrl>/models, so every model 9router
    # offers shows up as `9router/<id>` — pick one with /model or modelRoles in
    # ~/.omp/agent/config.yml, which stays writable and unmanaged.
    # The gateway requires an API key for both /models and inference; omp reads
    # it from NINEROUTER_API_KEY (same name Hermes uses). If that variable is
    # unset, omp sends the literal string as the key and gets a 401.
    home.file.".omp/agent/models.yml".text = lib.generators.toYAML { } {
      providers."9router" = {
        baseUrl =
          if myconfig.services.ai-gateway.enable or false then
            "http://127.0.0.1:20128/v1"
          else
            "http://bristlecone.netbird.cloud:20128/v1";
        api = "openai-completions";
        apiKey = "NINEROUTER_API_KEY";
        authHeader = true;
        discovery.type = "openai-models-list";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };

  nixos.always = { myconfig, ... }: {
    # Prebuilt nix-index database; puts a comma wrapped with it on PATH.
    imports = [ inputs.nix-index-database.nixosModules.nix-index ];
    programs.nix-index-database.comma.enable = true;

    # Hostname follows the denix host name; hosts that need a different one
    # (e.g. myrtle -> "sequoia-archive") just set networking.hostName themselves.
    networking.hostName = lib.mkDefault myconfig.host.name;

    home-manager.backupFileExtension = "backup";

    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;

    services.netbird.enable = true;
    services.resolved.enable = true;

    virtualisation = {
      podman.enable = true;
      containers.registries.search = [ "docker.io" ];
    };

    users.defaultUserShell = "/run/current-system/sw/bin/xonsh";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  darwin.always = { myconfig, ... }: {
    # Prebuilt nix-index database; puts a comma wrapped with it on PATH.
    imports = [ inputs.nix-index-database.darwinModules.nix-index ];
    programs.nix-index-database.comma.enable = true;

    networking.hostName = lib.mkDefault myconfig.host.name;

    home-manager.backupFileExtension = "backup";

    environment.systemPackages = sharedPackages;

    # Netbird VPN client daemon
    launchd.daemons.netbird = {
      serviceConfig = {
        Label = "io.netbird.client";
        # Create /var/run/netbird before starting — netbird needs this
        # directory to create its Unix socket for client-daemon IPC
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/mkdir -p /var/run/netbird && ${pkgs.netbird}/bin/netbird service run"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/netbird.out.log";
        StandardErrorPath = "/var/log/netbird.err.log";
      };
    };
  };
}
