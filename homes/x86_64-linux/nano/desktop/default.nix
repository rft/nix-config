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
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf config.modules.home.desktop.enable {
    programs.noctalia-shell.enable = true;
  };
}
