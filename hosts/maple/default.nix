{ delib, ... }:
delib.host {
  name = "maple";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "26.05";
    imports = [ ../../hardware/maple.nix ];

    # RTX 3070 (Ampere): nouveau leaves the DisplayPort outputs dark, so use
    # NVIDIA's driver with the open kernel modules (recommended for Turing+).
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;
    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
    };

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
    applications.gaming.enable = true;
    applications.archiving.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
