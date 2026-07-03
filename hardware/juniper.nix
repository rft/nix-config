# Disk layout applied by nixos-anywhere/disko on first install.
# Most KVM-based VPSes expose the disk as /dev/vda — check with `lsblk`
# on the target and adjust before installing if the provider differs.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02"; # BIOS boot partition for legacy-boot VPSes
          priority = 1;
        };
        esp = {
          size = "512M";
          type = "EF00";
          priority = 2;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
