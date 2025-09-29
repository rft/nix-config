{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    environment.systemPackages = with pkgs; [
      inputs.caelestia-shell.packages.${pkgs.system}.default
    ];
  };
}
