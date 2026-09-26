{ delib, lib, pkgs, ... }:
let
  # "Melancholic Forest" live wallpaper from moewalls.com (3840x2160, 60fps, 15s loop).
  # The download URL is an opaque token; the hash pins the exact file.
  video = pkgs.fetchurl {
    name = "melancholic-forest.mp4";
    url = "https://go.moewalls.com/download.php?video=Zp0HrxtPNbwvdeROCzbhkO88L5a6XtkOVPNtfZXkOMeKy9DeMTyKN0W4lSM%3D";
    hash = "sha256-6RmVyDgbkl5Sg0in/j8MfpOr1omFeBYh1n9fixoNAHM=";
  };

  # First frame of the loop, for noctalia's lock screen (it can't show video).
  still = pkgs.runCommandLocal "melancholic-forest.png" { } ''
    ${lib.getExe pkgs.ffmpeg-headless} -loglevel error -i ${video} -frames:v 1 $out
  '';
in
delib.module {
  name = "desktop.wallpaper";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.wallpaper.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  home.ifEnabled = {
    # Noctalia can't play video, so hand the background layer to mpvpaper.
    programs.noctalia.settings = {
      wallpaper.enabled = false;
      lockscreen.wallpaper = "${still}";
    };

    systemd.user.services.mpvpaper = {
      Unit = {
        Description = "Animated wallpaper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        # -p pauses playback while windows fully cover the wallpaper.
        ExecStart = "${lib.getExe pkgs.mpvpaper} -p -o \"no-audio loop hwdec=auto panscan=1.0\" '*' ${video}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
