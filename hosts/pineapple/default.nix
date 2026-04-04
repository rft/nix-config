{ delib, ... }:
delib.host {
  name = "pineapple";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    networking.hostName = "pineapple";
    homebrew.brews = [ "ollama" ];

    # Run ollama serve bound to all interfaces so other machines can reach it
    launchd.user.agents.ollama-serve = {
      serviceConfig = {
        ProgramArguments = [ "/opt/homebrew/bin/ollama" "serve" ];
        EnvironmentVariables.OLLAMA_HOST = "0.0.0.0";
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/ollama-serve.log";
        StandardErrorPath = "/tmp/ollama-serve.err";
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
