{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "editors.opencode";

  options = delib.singleEnableOption true;

  myconfig.always = { myconfig, ... }: {
    editors.opencode.enable = lib.mkDefault (myconfig.editors.enable or false);
  };

  home.ifEnabled = {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      policies = [
        {
          action = "provider.use";
          resource = "opencode";
          effect = "deny";
        }
      ];
    };
  };
}
