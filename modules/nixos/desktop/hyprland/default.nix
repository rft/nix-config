{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.hyprland.enable = true;
    programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

    environment.systemPackages = with pkgs; [
      wdisplays
      kanshi
      wofi
      hyprcursor
    ];
  };
}
