{ delib, lib, ... }:
let
  hardenedServiceConfig = import ../../lib/hardened-service-config.nix;
in
delib.module {
  name = "services.home-assistant";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.home-assistant.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled =
    { myconfig, ... }:
    {
      # Home Assistant
      services.home-assistant = {
        enable = true;
        openFirewall = true;
        extraComponents = [
          "hue"
          "xiaomi_miio"
          "google_translate"
          "met"
          "mqtt"
          "esphome"
          "cast"
          "radio_browser"
          # AirGradient ONE (I-9PSL) indoor monitors. Local polling over the
          # device's HTTP API — no cloud account and no MQTT involved. Needs
          # device firmware >= 3.1.1.
          "airgradient"
        ];
        config = {
          homeassistant = {
            name = "Home";
            unit_system = "metric";
            time_zone = myconfig.constants.timezone;
          };
          default_config = { };

          # The UI editors write to these files and then reload; without the
          # matching !include they are never read, so a saved automation/script/
          # scene never materialises and the frontend times out waiting for it.
          # configuration.yaml itself is a read-only store symlink, so the
          # includes have to be declared here rather than added from the UI.
          automation = "!include automations.yaml";
          script = "!include scripts.yaml";
          scene = "!include scenes.yaml";
        };
      };

      # !include on a missing file aborts startup, so seed the UI-managed files
      # before hass reads the config. Runs as the hass user in configDir.
      systemd.services.home-assistant.preStart = lib.mkAfter ''
        for f in automations.yaml scripts.yaml scenes.yaml; do
          [ -e "/var/lib/hass/$f" ] || echo "[]" > "/var/lib/hass/$f"
        done
      '';

      systemd.services.home-assistant.serviceConfig = lib.mapAttrs (_: lib.mkForce) (
        hardenedServiceConfig
        // {
          PrivateDevices = false; # May need device access for integrations
          RestrictNamespaces = false;
        }
      );

      # mDNS. Home Assistant's zeroconf listener binds UDP 5353 and receives
      # replies on that same port, so the default deny drops every response and
      # nothing is ever auto-discovered — AirGradient, esphome and cast all rely
      # on it. Outbound queries alone are not enough.
      networking.firewall.allowedUDPPorts = [ 5353 ];

      services.borgmatic.settings = {
        source_directories = [ "/var/lib/hass" ];
        sqlite_databases = [
          {
            name = "home-assistant";
            path = "/var/lib/hass/home-assistant_v2.db";
          }
        ];
        exclude_patterns = [
          "/var/lib/hass/home-assistant_v2.db*"
          "/var/lib/hass/*.log*"
          "/var/lib/hass/backups" # HA's own backups duplicate everything here
          "/var/lib/hass/tts"
        ];
      };
    };
}
