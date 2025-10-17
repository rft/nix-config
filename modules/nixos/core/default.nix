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
    watchexec
    rink
    inputs.nixcats-nvim.packages.${pkgs.system}.default
    pass
    gh
    tokei
    claude-code
    codex
    xonsh
  ];

  users.defaultUserShell = pkgs.xonsh;

  # Automatic garbage collection for all systems
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
