{ delib, ... }:
delib.host {
  name = "redwood";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "24.11";
    imports = [ ../../hardware/redwood.nix ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };
  };

  myconfig = {
    applications.enable = true;
    applications.creative.enable = true;
    applications.engineering.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
