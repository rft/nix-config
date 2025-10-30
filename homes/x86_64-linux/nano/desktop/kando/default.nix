{ config, lib, pkgs, ... }:
let
  cfg = config.modules.home.desktop;
  homeDir = config.home.homeDirectory;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kando
    ];

    home.file.".config/kando".source =
      config.lib.file.mkOutOfStoreSymlink "${homeDir}/nix-config/config/kando";

    systemd.user.services.kando = {
      Unit = {
        Description = "Kando pie menu";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kando}/bin/kando --ozone-platform-hint=auto";
        Restart = "on-failure";
        RestartSec = 5;
        Slice = "session.slice";
        Environment = [
          "ELECTRON_OZONE_PLATFORM_HINT=auto"
          "NIXOS_OZONE_WL=1"
        ];
      };
    };
  };
}
