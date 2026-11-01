{ delib, lib, pkgs, ... }:
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
      providers = {
        llama-cpp = {
          package = "@opencode/ai/providers/openai-compatible";
          name = "llama.cpp";
          settings = {
            baseURL = "http://pineapple.netbird.cloud:8080/v1";
          };
          models = {
            default = {
              name = "Default";
            };
          };
        };
      };
      model = "llama-cpp/default";
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
