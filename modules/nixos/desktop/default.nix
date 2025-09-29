{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop module";
  };

  imports = [
    ./awesome
    ./login
    ./hyprland
    ./caelestia
  ];
}
