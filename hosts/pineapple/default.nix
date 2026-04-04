{ delib, ... }:
delib.host {
  name = "pineapple";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    networking.hostName = "pineapple";
    homebrew.casks = [ "ollama" ];

    # Bind Ollama to all interfaces so other machines can reach it
    environment.variables.OLLAMA_HOST = "0.0.0.0";
  };

  myconfig = {
    constants.username = "astro";

    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
