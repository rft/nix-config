{
  delib,
  lib,
  ...
}:
delib.module {
  name = "config.darwin";

  darwin.always =
    { myconfig, ... }:
    {
      nix.enable = lib.mkDefault false;
      nix.gc.automatic = lib.mkForce false;
      system.primaryUser = myconfig.constants.username;
      system.stateVersion = lib.mkDefault 6;

      # "nano" is intentionally hardcoded: the flake sets denix's
      # homeManagerUser = "nano" for all hosts, and nix-darwin's home-manager
      # integration requires that user to exist even when
      # constants.username differs (e.g. "astro" on lemon/pineapple).
      users.users.nano = {
        home = "/Users/${myconfig.constants.username}";
      };

      security.pam.services.sudo_local.touchIdAuth = lib.mkDefault true;

      homebrew = {
        enable = lib.mkDefault true;
        onActivation.cleanup = lib.mkDefault "zap";
        taps = [
          # trusted: Homebrew 6 refuses to load casks from untrusted third-party taps.
          {
            name = "abue-ammar/tinycast";
            trusted = true;
          }
        ];
        brews = [ "mas" ];
        casks = [
          "discord"
          "spotify"
          "obs"
          "calibre"
          "anki"
          "audacity"
          "blender"
          "krita"
          "reaper"
          "rustdesk"
          "abue-ammar/tinycast/tinycast"
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
          "chatgpt"
          "vorssaint"
        ];
        masApps = {
          "Amphetamine" = 937984704;
          "ProDrafts" = 1545810067;

          # Free Safari extensions; enable and grant website access in Safari Settings.
          # Bitwarden's Safari extension requires the Mac App Store desktop app.
          "Bitwarden" = 1352778147;
          "uBlock Origin Lite" = 6745342698;
          "Save to Raindrop.io" = 1549370672;
          "SingleFile for Safari" = 6444322545;
          "Kagi for Safari" = 1622835804;
          "Userscripts" = 1463298887;
          "Vimari" = 1480933944;
          "Kitty Progress Bar" = 6780563808;
          "Hover for Safari" = 1540705431;
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
