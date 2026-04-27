{ delib, pkgs, ... }:
delib.host {
  name = "pineapple";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    networking.hostName = "pineapple";
    homebrew.casks = [ "google-chrome" ];

    environment.systemPackages = [ pkgs.llama-cpp ];

    launchd.user.agents.llama-server = {
      serviceConfig = {
        Label = "com.llama-cpp.server";
        ProgramArguments = [
          "${pkgs.llama-cpp}/bin/llama-server"
          "--host" "0.0.0.0"
          "--port" "8080"
          "--model" "/Users/astro/Models/default.gguf"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/llama-server.log";
        StandardErrorPath = "/tmp/llama-server.err";
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
