{
  delib,
  inputs,
  pkgs,
  lib,
  ...
}:
delib.host {
  name = "installer";
  type = "installer";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "25.11";

    imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    ];

    # Embed the flake source so nixos-install works offline
    environment.etc."nixos-config".source = inputs.self;

    # Override SDDM autologin to the nano user (ISO defaults to nixos)
    services.displayManager.autoLogin = {
      enable = true;
      user = lib.mkForce "nano";
    };

    # Set empty password for the live environment
    users.users.nano.initialHashedPassword = "";

    # Extra packages useful for disk setup and installation
    environment.systemPackages = with pkgs; [
      parted
      dosfstools
      e2fsprogs
      btrfs-progs
      ntfs3g
    ];

    # Use zstd compression (level 6 for fast builds, bump to 19 for release)
    isoImage.squashfsCompression = "zstd -Xcompression-level 19";

    networking.hostName = lib.mkForce "installer";
  };

  myconfig = {
    fonts.enable = true;
  };
}
