{ delib, lib, ... }:
delib.module {
  name = "config.darwin";

  darwin.always = { myconfig, ... }: {
    nix.enable = lib.mkDefault false;
    nix.gc.automatic = lib.mkForce false;
    system.primaryUser = myconfig.constants.username;
    system.stateVersion = lib.mkDefault 6;

    users.users.nano = {
      home = "/Users/${myconfig.constants.username}";
    };

    security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;

    homebrew = {
      enable = lib.mkDefault true;
      onActivation.cleanup = lib.mkDefault "zap";
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
        "plover"
        "utm"
        "espanso"
        "obsidian"
        "claude"
      ];
      masApps = {
        "Amphetamine" = 937984704;
        "ProDrafts" = 1545810067;
      };
    };

    system.defaults = {
      dock = {
        autohide = lib.mkDefault false;
        mru-spaces = lib.mkDefault false;
        minimize-to-application = lib.mkDefault true;
        show-recents = lib.mkDefault false;
      };
      finder = {
        AppleShowAllExtensions = lib.mkDefault true;
        FXPreferredViewStyle = lib.mkDefault "clmv";
        ShowPathbar = lib.mkDefault true;
        ShowStatusBar = lib.mkDefault true;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = lib.mkDefault true;
        AppleInterfaceStyle = lib.mkDefault "Dark";
        "com.apple.swipescrolldirection" = lib.mkDefault true;
      };
      trackpad = {
        Clicking = lib.mkDefault true;
        TrackpadThreeFingerDrag = lib.mkDefault true;
      };
    };
  };
}
