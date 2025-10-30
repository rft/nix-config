{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.modules.home.desktop.enable {
    home.file.".config/niri".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/niri";

    home.packages = [ pkgs.niri ];

    systemd.user.services.niri = {
      Unit = {
        Description = "Niri Wayland compositor";
        BindsTo = ["graphical-session.target"];
        Before = ["graphical-session.target"];
        Wants = [
          "graphical-session-pre.target"
          "xdg-desktop-autostart.target"
        ];
        After = ["graphical-session-pre.target"];
      };
      Service = {
        Slice = "session.slice";
        Type = "notify";
        ExecStart = "${pkgs.niri}/bin/niri --session";
      };
    };

    systemd.user.targets."niri-shutdown" = {
      Unit = {
        Description = "Shutdown running niri session";
        DefaultDependencies = false;
        StopWhenUnneeded = true;
        Conflicts = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];
        After = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];
      };
    };
  };
}
