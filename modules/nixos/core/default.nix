{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./xonsh.nix
  ];

  home-manager.backupFileExtension = "backup";

  environment.systemPackages = with pkgs; [
    yazi
    picat
    zellij
    ripgrep
    atuin
    distrobox
    podman
    podman-tui
    fd
    bat
    fzf
    git
    #neovim
    jq
    yq
    tealdeer
    #hygg it's in unstable will add later
    zoxide
    bottom
    pandoc
    ffmpeg_7-full
    procs
    tldr
    lazygit
    visidata
    syncthing
    rsync
    rclone
    watchexec
    rink
    inputs.nixcats-nvim.packages.${pkgs.system}.default
    pass
    gh
    tokei
    rr
    hexyl
    # pwndbg
    procps
    util-linux
    sysstat
    iproute2
    numactl
    tcpdump
    msr-tools
    cpuid
    tiptop
    ethtool
    nicstat
    bpftrace
    difftastic
    claude-code
    codex
    tio
  ];

  virtualisation = {
    podman.enable = true;
    containers.registries.search = [ "docker.io" ];
  };

  users.defaultUserShell = "/run/current-system/sw/bin/xonsh";

  # Automatic garbage collection for all systems
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
