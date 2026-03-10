{ delib, ... }:
delib.host {
  name = "bristlecone";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "25.11";
    imports = [ ./hardware-configuration.nix ];

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "bristlecone";
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

    # KDE Plasma 6
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.xkb = { layout = "us"; variant = ""; };
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
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
