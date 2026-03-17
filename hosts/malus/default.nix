{ delib, ... }:
delib.host {
  name = "malus";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    system.stateVersion = 6;
    networking.hostName = "malus";

    security.pam.services.sudo_local.touchIdAuth = true;

    homebrew = {
      enable = true;
      onActivation.cleanup = "zap";
      casks = [
        "discord"
        "spotify"
        "obs"
        "mpv"
        "calibre"
        "anki"
        "audacity"
        "blender"
        "krita"
        "reaper"
        "raycast"
        "shortcat"
        "linearmouse"
        "orion"
        "karabiner-elements"
        "iina"
      ];
      masApps = {
        "Amphetamine" = 937984704;
      };
    };

    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = true;
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleInterfaceStyle = "Dark";
        "com.apple.swipescrolldirection" = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  myconfig = {
    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
