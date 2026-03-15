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
    pkgs.yosys
    pkgs.surfer
  ];
}
