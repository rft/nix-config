{ delib, lib, ... }:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.jellyfin";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.jellyfin.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # Jellyfin media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.jellyfin.serviceConfig = lib.mapAttrs (_: lib.mkForce) (
      hardenedServiceConfig
      // {
        ProtectSystem = "strict";
        RestrictNamespaces = false;
        ReadWritePaths = [
          "/var/lib/jellyfin"
          "/var/cache/jellyfin"
          "/var/log/jellyfin"
        ];
      }
    );
    systemd.services.jellyfin.environment.JELLYFIN_HttpListenerHost__BindAddresses = "0.0.0.0";
    systemd.tmpfiles.rules = [ "d /var/log/jellyfin 0750 jellyfin jellyfin -" ];

    services.borgmatic.settings = {
      source_directories = [ "/var/lib/jellyfin" ];
      sqlite_databases = [
        {
          name = "jellyfin";
          path = "/var/lib/jellyfin/data/jellyfin.db";
        }
      ];
      exclude_patterns = [
        "/var/lib/jellyfin/data/jellyfin.db*"
        "/var/lib/jellyfin/log"
      ];
    };
  };
}
