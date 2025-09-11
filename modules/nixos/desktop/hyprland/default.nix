{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  environment.systemPackages = with pkgs; [
    wdisplays
    kanshi
    wofi
  ];
}
