{ delib, lib, ... }:
delib.module {
  name = "services.samba";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.samba.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled =
    { myconfig, ... }:
    {
      # Samba base setup. Shares are declared where they belong: the scanner's
      # in services.scanner, host-specific ones in the host config.
      services.samba = {
        enable = true;
        openFirewall = true;
        nmbd.enable = true; # NetBIOS, so the scanner's "Browse Network" finds us
        settings.global = {
          "workgroup" = "WORKGROUP";
          "server string" = myconfig.host.name;
          "security" = "user";
          "map to guest" = "never";
          "load printers" = "no";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";
        };
      };

      # smbpasswd database
      services.borgmatic.settings.source_directories = [ "/var/lib/samba/private" ];
    };
}
