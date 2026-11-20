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

  nixos =
    { myconfig, ... }:
    let
      username = myconfig.constants.username;

      # install-host HOST — install a flake host onto the disks mounted at /mnt.
      # Generates hardware/HOST.nix, installs, sets the user password and leaves
      # the checkout at ~/nix-config on the new system.
      installHost = pkgs.writeShellApplication {
        name = "install-host";
        runtimeInputs = with pkgs; [
          git
          util-linux
          nixos-install-tools
        ];
        text = ''
          host="''${1:?usage: install-host HOST   (partition and mount the target at /mnt first)}"
          repo="$HOME/nix-config"

          mountpoint -q /mnt || {
            echo "Nothing mounted at /mnt — partition, then mount root at /mnt (and EFI at /mnt/boot)." >&2
            exit 1
          }

          # Prefer a fresh clone (has git history); fall back to the snapshot on the ISO.
          rm -rf "$repo"
          if git clone --quiet https://github.com/rft/nix-config.git "$repo" &&
            [ -f "$repo/hosts/$host/default.nix" ]; then
            echo "Using a fresh clone of github.com/rft/nix-config"
          else
            rm -rf "$repo"
            cp -r --no-preserve=mode /etc/nixos-config "$repo"
            echo "Using the flake snapshot embedded in this ISO (no git history)"
          fi
          [ -f "$repo/hosts/$host/default.nix" ] || {
            echo "No hosts/$host/default.nix in the flake — add the host first (docs/SETUP.md)." >&2
            exit 1
          }

          sudo nixos-generate-config --root /mnt --show-hardware-config | tee "$repo/hardware/$host.nix" >/dev/null
          [ -d "$repo/.git" ] && git -C "$repo" add -A

          echo "Evaluating $host..."
          nix eval --raw "$repo#nixosConfigurations.$host.config.system.build.toplevel.drvPath" >/dev/null

          sudo nixos-install --flake "$repo#$host" --no-root-passwd

          echo "Set the password for ${username}:"
          until sudo nixos-enter --root /mnt -c 'passwd ${username}'; do :; done

          sudo mkdir -p "/mnt/home/${username}"
          sudo cp -r "$repo" "/mnt/home/${username}/nix-config"
          sudo nixos-enter --root /mnt -c 'chown -R ${username}:users /home/${username}/nix-config'

          echo
          echo "Done. After reboot, commit hardware/$host.nix from ~/nix-config and push."
        '';
      };
    in
    {
      system.stateVersion = "25.11";

      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
      ];

      # Embed the flake source so nixos-install works offline
      environment.etc."nixos-config".source = inputs.self;

      # Override SDDM autologin to the nano user (ISO defaults to nixos)
      services.displayManager.autoLogin = {
        enable = true;
        user = lib.mkForce username;
      };

      # Set empty password for the live environment
      users.users.${username}.initialHashedPassword = "";

      # Extra packages useful for disk setup and installation
      environment.systemPackages = with pkgs; [
        installHost
        parted
        dosfstools
        e2fsprogs
        btrfs-progs
        ntfs3g
      ];

      # zstd level 19 for the smallest image; drop to 6 for fast test builds
      isoImage.squashfsCompression = "zstd -Xcompression-level 19";

      networking.hostName = lib.mkForce "installer";
    };

  myconfig = {
    fonts.enable = true;
  };
}
