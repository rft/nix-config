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
    # objdump
    # perf
    # pwndbg
    #hygg it's in unstable will add later
    #neovim
    atuin
    bandwhich
    bat
    binsider
    bottom
    bpftrace
    claude-code
    codex
    copilot-cli
    cpuid
    csvlens
    difftastic
    distrobox
    dua
    ethtool
    fd
    ffmpeg_7-full
    fzf
    gemini-cli
    gh
    git
    hexyl
    inputs.nixcats-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    iproute2
    jq
    lazygit
    msr-tools
    nicstat
    numactl
    oxker
    pandoc
    pass
    picat
    podman
    podman-tui
    procps
    procs
    rclone
    rink
    ripgrep
    rr
    rsync
    syncthing
    sysstat
    tcpdump
    tealdeer
    tio
    tiptop
    tokei
    trippy
    util-linux
    visidata
    watchexec
    wget
    yazi
    yq
    yt-dlp
    zellij
    zoxide
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
