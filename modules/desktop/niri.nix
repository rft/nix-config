{ delib, lib, pkgs, ... }:
delib.module {
  name = "desktop.niri";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.niri.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  home.ifEnabled = {
    home.file.".config/niri".source =
      pkgs.runCommandLocal "niri-config-symlink" {} "ln -s /home/nano/nix-config/config/niri $out";

    home.packages = with pkgs; [
      niri
      kanshi
      wdisplays
    ];

    systemd.user.services.niri = {
      Unit = {
        Description = "Niri Wayland compositor";
        BindsTo = [ "graphical-session.target" ];
        Before = [ "graphical-session.target" ];
        Wants = [
          "graphical-session-pre.target"
          "xdg-desktop-autostart.target"
        ];
        After = [ "graphical-session-pre.target" ];
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
