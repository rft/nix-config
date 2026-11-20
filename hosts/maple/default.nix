{ delib, ... }:
delib.host {
  name = "maple";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "26.05";
    imports = [ ../../hardware/maple.nix ];

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
