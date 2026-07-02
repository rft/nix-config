{ delib, pkgs, ... }:
let
  username = "astro";
  homeDir = "/Users/${username}";
in
delib.host {
  name = "pineapple";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    homebrew.casks = [ "google-chrome" ];

    environment.systemPackages = [
      pkgs.llama-cpp
      pkgs.colima
      pkgs.docker-client
    ];

    launchd.user.agents.llama-server = {
      serviceConfig = {
        Label = "com.llama-cpp.server";
        ProgramArguments = [
          "${pkgs.llama-cpp}/bin/llama-server"
          "--host" "0.0.0.0"
          "--port" "8080"
          "--model" "${homeDir}/Models/default.gguf"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${homeDir}/Library/Logs/llama-server.log";
        StandardErrorPath = "${homeDir}/Library/Logs/llama-server.err";
      };
    };
  };

  myconfig = {
    constants.username = username;

    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
