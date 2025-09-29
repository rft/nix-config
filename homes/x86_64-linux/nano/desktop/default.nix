{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    modules.home.desktop.enable = lib.mkEnableOption "home desktop module";
  };

  imports = [
    ./awesome
    ./hyprland
    ./caelestia
  ];
}
