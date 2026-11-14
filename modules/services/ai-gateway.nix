{
  delib,
  lib,
  pkgs,
  ...
}:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.ai-gateway";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.ai-gateway.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # 9router AI gateway: one shared instance so provider logins, OAuth
    # refresh and quota tracking live in one place; agents on the other hosts
    # point ANTHROPIC_BASE_URL / OpenAI base URLs at it over netbird.
    #
    # Runs the bundled Next.js server directly rather than the `9router` CLI,
    # which shows an interactive menu, detaches its child and npm-installs
    # sqlite/tray deps into $HOME at startup. The server uses node:sqlite and
    # the sql.js copy bundled in app/node_modules, so nothing is fetched.
    #
    # Dashboard login defaults to "123456" and /v1 needs no API key until one
    # is required in the dashboard — hence netbird-only (see firewall below).
    systemd.services."9router" = {
      description = "9router AI gateway";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        NODE_ENV = "production";
        DATA_DIR = "/var/lib/9router";
        NEXT_CACHE_DIR = "%C/9router";
        NODE_PATH = "${pkgs._9router}/lib/node_modules/9router/app/node_modules";
        HOSTNAME = "0.0.0.0";
        PORT = "20128";
      };
      serviceConfig = hardenedServiceConfig // {
        ExecStart = "${lib.getExe pkgs.unstable.nodejs} --dns-result-order=ipv4first custom-server.js";
        WorkingDirectory = "${pkgs._9router}/lib/node_modules/9router/app";
        DynamicUser = true;
        StateDirectory = "9router";
        StateDirectoryMode = "0700";
        CacheDirectory = "9router";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ 20128 ];

    # provider logins / OAuth tokens
    services.borgmatic.settings.source_directories = [ "/var/lib/private/9router" ];
  };
}
