{ delib, ... }:
delib.host {
  name = "myrtle";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "24.11";
    imports = [ ../../hardware/myrtle.nix ];

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };

    virtualisation.vmware.guest.enable = true;

    # Deliberately different from the host name: this machine took over
    # archive duty from sequoia and keeps its old network identity.
    networking.hostName = "sequoia-archive";
    time.timeZone = "America/Phoenix";
  };

  myconfig = {
    applications.enable = true;
    applications.archiving.enable = true;
    applications.creative.enable = false;
    applications.engineering.enable = false;
    desktop.enable = true;
    programs.programming.enable = false;
  };
}
