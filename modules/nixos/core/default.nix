{ lib, pkgs, inputs, config, ...
}:
{
  imports = [
      ./xonsh.nix
  ];

  home-manager.backupFileExtension = "backup";

  environment.systemPackages = with pkgs; [
    helix
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
    xplr
    bottom
    pandoc
    ffmpeg_7-full
    procs
    tldr
    lazygit
    visidata
    syncthing

    inputs.nixcats-nvim.packages.${pkgs.system}.default
    #xonsh
  ];

  users.defaultUserShell = pkgs.nushell;
}
