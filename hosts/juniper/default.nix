{ delib, inputs, lib, ... }:
delib.host {
  name = "juniper";
  type = "server";
  system = "x86_64-linux";

  home.home.stateVersion = "25.11";

  nixos = { myconfig, ... }: {
    system.stateVersion = "25.11";
    imports = [
      inputs.disko.nixosModules.disko
      ../../hardware/juniper.nix
    ];

    # Generic KVM/QEMU VPS hardware (virtio)
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];

    # Hybrid BIOS+UEFI GRUB so the layout boots on either VPS firmware;
    # disko supplies boot.loader.grub.devices from the disk layout.
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    # Small VPSes rarely have swap partitions — compress RAM instead
    zramSwap.enable = true;

    time.timeZone = "America/Phoenix";

    networking.firewall.enable = true;
    # Keep SSH reachable over the netbird tunnel (wt0) even if port 22
    # is later closed on the public interface (see docs/VPS.md).
    networking.firewall.trustedInterfaces = [ "wt0" ];

    # nixos-anywhere installs and deploy-rs pushes as root over SSH.
    # Password auth stays disabled globally via core.ssh — keys only.
    services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
    users.users.root.openssh.authorizedKeys.keys = builtins.attrValues myconfig.constants.sshKeys;
  };
}
