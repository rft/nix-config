{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.home.desktop;
in
{
  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      theme = ./nord.rasi;
    };

    home.packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rofi-desktop
      pkgs.libdbusmenu
    ];

    systemd.user.services.rofi-appmenu-service = {
      Unit = {
        Description = "AppMenu registrar for rofi-desktop HUD";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rofi-desktop}/bin/rofi-appmenu-service";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = "PYTHONUNBUFFERED=1";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
