{ delib, ... }:
delib.host {
  name = "bristlecone";
  type = "server";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = { myconfig, ... }: {
    system.stateVersion = "25.11";
    imports = [ ../../hardware/bristlecone.nix ];

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;

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

    # Firewall
    networking.firewall.enable = true;

    # Allow project executables without relaxing hardening elsewhere.
    nix-mineral.filesystems.normal."/srv/projects" = {
      enable = true;
      options = {
        noexec = false;
        exec = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/projects 0750 ${myconfig.constants.username} users -"
    ];
  };

  myconfig = {
    services.enable = true;
    security.enable = true;
  };
}
