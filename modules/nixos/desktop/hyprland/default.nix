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

    environment.systemPackages = with pkgs; [
      wdisplays
      kanshi
      wofi
      hyprcursor
    ];
  };
}
