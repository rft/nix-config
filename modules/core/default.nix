{ delib, inputs, pkgs, ... }:
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
    oxker
    pandoc
    pass
    picat
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
  ];
in
delib.module {
  name = "core";

  nixos.always = {
    home-manager.backupFileExtension = "backup";

    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;

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

    nix.gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };
}
