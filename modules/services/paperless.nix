{ delib, lib, ... }:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.paperless";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.paperless.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # Paperless document management. The scanner ingest path (relocated
    # consume dir, SFTP jail, SMB share) lives in services.scanner.
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      settings.PAPERLESS_OCR_LANGUAGE = "eng";
    };

    systemd.services.paperless-web.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
    systemd.services.paperless-scheduler.serviceConfig = lib.mapAttrs (
      _: lib.mkForce
    ) hardenedServiceConfig;
    systemd.services.paperless-consumer.serviceConfig = lib.mapAttrs (
      _: lib.mkForce
    ) hardenedServiceConfig;

    networking.firewall.allowedTCPPorts = [ 28981 ];

    services.borgmatic.settings = {
      source_directories = [ "/var/lib/paperless" ];
      sqlite_databases = [
        {
          name = "paperless";
          path = "/var/lib/paperless/db.sqlite3";
        }
      ];
      exclude_patterns = [
        "/var/lib/paperless/db.sqlite3*"
        "/var/lib/paperless/celerybeat-schedule.db*"
        "/var/lib/paperless/index" # rebuildable: paperless-manage document_index reindex
        "/var/lib/paperless/log"
        "/var/lib/paperless/consume"
      ];
    };
  };
}
