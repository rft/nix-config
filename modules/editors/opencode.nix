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
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://pineapple.netbird.cloud:11434/v1";
          };
          models = {
            "gemma4:26b" = {
              name = "Gemma 4 26B";
            };
          };
        };
      };
      model = "ollama/gemma4:26b";
      disabled_providers = [ "opencode" ];
    };
  };
}
