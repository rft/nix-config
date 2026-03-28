{ delib, lib, pkgs, config, ... }:
delib.host {
  name = "lemon";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    nix.enable = false;
    nix.gc.automatic = lib.mkForce false;
    system.primaryUser = "astro";
    system.stateVersion = 6;
    networking.hostName = "lemon";

    users.users.nano = {
      home = "/Users/astro";
    };

    security.pam.services.sudo_local.touchIdAuth = true;

    homebrew = {
      enable = true;
      onActivation.cleanup = "zap";
      brews = [ "mas" ];
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
        autohide = false;
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
    constants.username = "astro";

    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
