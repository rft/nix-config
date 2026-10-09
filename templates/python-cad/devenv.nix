{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    package = pkgs.python312;
    venv.enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  packages = [
    pkgs.mesa
    pkgs.libGL
    pkgs.libx11
    pkgs.libxrender
    pkgs.expat
    pkgs.zlib
  ];
}
