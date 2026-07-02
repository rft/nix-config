{ delib, ... }:
delib.host {
  name = "cottonwood";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "24.11";
    imports = [ ../../hardware/cottonwood.nix ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        extraConfig = ''
          GRUB_GFXMODE=auto
          GRUB_GFXPAYLOAD_LINUX=keep
        '';
      };
    };
    boot.kernelParams = [ "fbcon=rotate:1" ];
  };

  myconfig = {
    applications.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
