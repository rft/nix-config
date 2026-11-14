{ delib, lib, ... }:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.n8n";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.n8n.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # n8n workflow automation
    services.n8n = {
      enable = true;
      openFirewall = true;
      environment.N8N_SECURE_COOKIE = "false";
    };

    systemd.services.n8n.serviceConfig = lib.mapAttrs (_: lib.mkForce) (
      hardenedServiceConfig
      // {
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/n8n" ];
      }
    );

    services.borgmatic.settings = {
      source_directories = [ "/var/lib/private/n8n" ];
      sqlite_databases = [
        {
          name = "n8n";
          path = "/var/lib/private/n8n/.n8n/database.sqlite";
        }
      ];
      exclude_patterns = [
        "/var/lib/private/n8n/.n8n/database.sqlite*"
        "/var/lib/private/n8n/.cache"
      ];
    };
  };
}
