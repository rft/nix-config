{ delib, lib, ... }:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.changedetection";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.changedetection.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # changedetection.io (website change monitoring)
    services.changedetection-io = {
      enable = true;
      listenAddress = "0.0.0.0";
      behindProxy = true;
      playwrightSupport = true;
    };

    systemd.services.changedetection-io.serviceConfig = lib.mapAttrs (_: lib.mkForce) (
      hardenedServiceConfig
      // {
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/changedetection-io" ];
      }
    );

    networking.firewall.allowedTCPPorts = [ 5000 ];

    services.borgmatic.settings.source_directories = [ "/var/lib/changedetection-io" ];
  };
}
