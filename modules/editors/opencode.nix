{ delib, lib, ... }:
delib.module {
  name = "editors.opencode";

  options = delib.singleEnableOption true;

  myconfig.always = { myconfig, ... }: {
    editors.opencode.enable = lib.mkDefault (myconfig.editors.enable or false);
  };

  home.ifEnabled = {
    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = {
        llama-cpp = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama.cpp";
          options = {
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
      disabled_providers = [ "opencode" ];
    };
  };
}
