{ delib, pkgs, inputs, ... }:
let
  karabinerConfig = pkgs.writeText "karabiner.json" (builtins.toJSON {
    profiles = [
      {
        name = "Default profile";
        selected = true;
        virtual_hid_keyboard = {
          keyboard_type_v2 = "ansi";
        };
        complex_modifications = {
          rules = [
            {
              description = "Caps Lock: tap for Escape, hold for Control";
              manipulators = [
                {
                  type = "basic";
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = [ "any" ];
                  };
                  to = [
                    {
                      key_code = "left_control";
                      lazy = true;
                    }
                  ];
                  to_if_alone = [
                    { key_code = "escape"; }
                  ];
                }
              ];
            }
          ];
        };
      }
    ];
  });
in
delib.host {
  name = "lemon";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  home.home.activation.karabinerConfig =
    inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DEST="$HOME/.config/karabiner"
      mkdir -p "$DEST"
      cp -f ${karabinerConfig} "$DEST/karabiner.json"
      chmod 600 "$DEST/karabiner.json"
    '';

  darwin = {
    homebrew.casks = [ "shottr" "topnotch" "typewhisper/tap/typewhisper" ];
    system.defaults.dock.autohide = true;

    # Free up ⌥⌘Space for nehir's command palette by disabling macOS's
    # built-in "Show Finder search window" Spotlight shortcut (symbolic
    # hotkey 65). Takes effect after a logout.
    system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."65".enabled = false;
  };

  myconfig = {
    constants.username = "astro";

    applications.enable = true;
    desktop.nehir.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
