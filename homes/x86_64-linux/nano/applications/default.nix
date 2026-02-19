{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    modules.home.applications.enable = lib.mkEnableOption "home applications module";
  };

  imports = [
    ./floorp
    ./kdenlive
  ];
}
