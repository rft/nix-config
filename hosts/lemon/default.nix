{ delib, ... }:
delib.host {
  name = "lemon";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    networking.hostName = "lemon";
  };

  myconfig = {
    constants.username = "astro";

    applications.enable = true;
    programs.programming.enable = true;
    programs.programming.cloud.enable = true;
    fonts.enable = true;
  };
}
