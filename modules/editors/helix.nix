{ delib, lib, pkgs, ... }:
delib.module {
  name = "editors.helix";

  options = delib.singleEnableOption true;

  myconfig.always = { myconfig, ... }: {
    editors.helix.enable = lib.mkDefault (myconfig.editors.enable or false);
  };

  home.ifEnabled = {
    programs.helix = {
      enable = true;
      settings = {
        theme = "monokai_pro_spectrum";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
      ];
      themes = {
        monokai_pro_spectrum = {
          "inherits" = "monokai_pro_spectrum";
        };
      };
    };
  };
}
