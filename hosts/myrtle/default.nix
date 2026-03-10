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

    networking.hostName = "sequoia-archive";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Phoenix";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    services.xserver = {
      enable = true;
      xkb = { layout = "us"; variant = ""; };
    };
    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    programs.firefox.enable = true;
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
