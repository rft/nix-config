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
        # os-prober scans every NTFS disk via grub-mount and takes ~25 min here,
        # so boot Windows through a fixed entry on its EFI partition instead.
        useOSProber = false;
        extraEntries = ''
          menuentry "Windows (NVMe 1TB)" {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root 54DE-3FE6
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
          menuentry "Windows (SATA 700GB)" {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root 04F4-F660
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
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
