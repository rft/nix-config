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
    ./niri
    ./kando
    ./rofi
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf config.modules.home.desktop.enable {
    programs.noctalia-shell = {
      enable = true;
      settings.colorSchemes.predefinedScheme = "Nord";
    };
  };
}
