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

  home.always = {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };

  nixos.always = { myconfig, ... }: {
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
