{ delib, ... }:
delib.host {
  name = "redwood";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "24.11";
    imports = [ ./hardware-configuration.nix ];

    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
      };
    };

    networking.hostName = "redwood";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Los_Angeles";

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
      layout = "us";
      xkbVariant = "";
    };
    services.printing.enable = true;

    hardware.pulseaudio.enable = false;
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
    applications.creative.enable = true;
    applications.engineering.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
