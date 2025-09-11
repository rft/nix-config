{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    inputs.caelestia-shell.packages.${pkgs.system}.default
  ];

}
