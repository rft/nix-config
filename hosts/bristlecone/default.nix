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
    time.timeZone = myconfig.constants.timezone;

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

    # Back up the share along with the service state (services.backup).
    # /srv/projects is left out on purpose — it lives in remote git repos.
    services.borgmatic.settings.source_directories = [ "/srv/share" ];

    # General-purpose SMB share. Samba itself (globals, firewall, nmbd) is set
    # up in services.samba; the password is set out-of-band with
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
