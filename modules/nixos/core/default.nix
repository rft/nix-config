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
    distrobox
    podman
    podman-tui
    fd
    bat
    fzf
    git
    #neovim
    jq
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

    inputs.nixcats-nvim.packages.${pkgs.system}.default
    #xonsh
  ];

  users.defaultUserShell = pkgs.nushell;
}
