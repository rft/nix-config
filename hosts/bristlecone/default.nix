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
      "d /srv/share 0750 ${myconfig.constants.username} users -"
    ];

    # General-purpose SMB share. Samba itself (globals, firewall, nmbd) is set
    # up in the services module; the password is set out-of-band with
    # `sudo smbpasswd -a ${myconfig.constants.username}`.
    #
    # 445 stays LAN-open for the scanner's share, so this one is fenced to
    # NetBird peers (CGNAT range) by Samba itself rather than the firewall.
    # The default reverse-path filter drops LAN packets spoofing a wt0 address.
    services.samba.settings.share = {
      "path" = "/srv/share";
      "browseable" = "yes";
      "read only" = "no";
      "valid users" = myconfig.constants.username;
      "hosts allow" = "100.64.0.0/10";
      "create mask" = "0644";
      "directory mask" = "0755";
    };

    # macOS interop: Apple SMB extensions so Finder keeps tags, resource
    # forks and metadata, and doesn't litter ._ files. Samba recommends
    # loading fruit globally so every share agrees on it.
    services.samba.settings.global = {
      "vfs objects" = "catia fruit streams_xattr";
      "fruit:aapl" = "yes";
      "fruit:metadata" = "stream";
      "fruit:model" = "MacSamba";
      "fruit:nfs_aces" = "no";
      "fruit:wipe_intentionally_left_blank_rfork" = "yes";
      "fruit:delete_empty_adfiles" = "yes";
    };
  };

  myconfig = {
    services.enable = true;
    security.enable = true;
  };
}
