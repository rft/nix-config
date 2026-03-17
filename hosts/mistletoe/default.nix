{ delib, inputs, ... }:
delib.host {
  name = "mistletoe";
  type = "wsl";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "25.05";
    imports = [ inputs.nixos-wsl.nixosModules.wsl ];

    wsl.enable = true;
    wsl.defaultUser = "nano";

    programs.nix-ld.enable = true;
    networking.hostName = "mistletoe";
  };

  myconfig = {
    editors.enable = true;
    programs.programming.enable = true;
    programs.programming.analysis.enable = true;
    programs.programming.cloud.enable = true;
  };
}
