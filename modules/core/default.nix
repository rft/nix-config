{
  delib,
  inputs,
  pkgs,
  ...
}:
let
  sharedPackages = with pkgs; [
    atuin
    bandwhich
    bat
    binsider
    bottom
    claude-code
    codex
    copilot-cli
    csvlens
    difftastic
    dua
    fd
    ffmpeg_7-full
    fzf
    gemini-cli
    gh
    git
    hexyl
    inputs.nixcats-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    jq
    lazygit
    netbird
    opencode
    oxker
    pandoc
    pass
    procs
    rclone
    rink
    ripgrep
    rsync
    syncthing
    tealdeer
    tio
    tokei
    trippy
    visidata
    watchexec
    wget
    yazi
    yq
    yt-dlp
    zellij
    zoxide
  ];

  linuxOnlyPackages = with pkgs; [
    bpftrace
    cpuid
    distrobox
    ethtool
    iproute2
    msr-tools
    nicstat
    numactl
    podman
    podman-tui
    procps
    rr
    sysstat
    tcpdump
    util-linux
    wl-clipboard
    picat
  ];
in
delib.module {
  name = "core";

  home.always = {
    home.packages = with pkgs; [ ripgrep fd ];
  };

  nixos.always = {
    home-manager.backupFileExtension = "backup";

    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;

    services.netbird.enable = true;
    services.resolved.enable = true;

    programs.ssh.extraConfig = ''
      Include /etc/ssh/ssh_config.d/*
    '';

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

  darwin.always = {
    home-manager.backupFileExtension = "backup";

    environment.systemPackages = sharedPackages;

    # Netbird VPN client daemon
    launchd.daemons.netbird = {
      serviceConfig = {
        Label = "io.netbird.client";
        # Create /var/run/netbird before starting — netbird needs this
        # directory to create its Unix socket for client-daemon IPC
        ProgramArguments = [
          "/bin/sh" "-c"
          "/bin/mkdir -p /var/run/netbird && ${pkgs.netbird}/bin/netbird service run"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/var/log/netbird.out.log";
        StandardErrorPath = "/var/log/netbird.err.log";
      };
    };

    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
