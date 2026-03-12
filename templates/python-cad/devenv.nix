{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  packages = [
    pkgs.mesa
    pkgs.libGL
    pkgs.xorg.libX11
  ];
}
