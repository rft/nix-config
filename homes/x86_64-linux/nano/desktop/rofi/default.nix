{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.home.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = ./nord.rasi;
    };
  };
}
