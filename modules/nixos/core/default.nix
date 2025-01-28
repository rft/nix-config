{ lib, pkgs, inputs, config, ...
}:
{
  imports = [
      ./xonsh.nix
  ];

  environment.systemPackages = with pkgs; [
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
}
