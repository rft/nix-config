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
    networking.hostName = "lemon";
    homebrew.casks = [ "topnotch" ];
  };

  myconfig = {
    constants.username = "astro";

    applications.enable = true;
    desktop.paneru.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
