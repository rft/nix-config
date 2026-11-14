{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "services.mqtt";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.mqtt.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      mosquitto # mosquitto_passwd / mosquitto_sub for broker bootstrap + debugging
    ];

    # Mosquitto MQTT broker. Home Assistant talks to it over localhost; IoT
    # devices reach it from the LAN, so 1883 is firewall-opened below.
    #
    # No blanket `pattern readwrite #`: patterns apply to every authenticated
    # user, which would make the per-user ACLs below meaningless. Anonymous
    # access is already off (mosquitto 2.x default), so each client
    # authenticates as a named user and gets only the topics it needs.
    #
    # All users stay in this one listener: `listeners` is a list, so a second
    # module defining its own entry would add a second listener, not a user.
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.hass = {
            acl = [ "readwrite #" ];
            hashedPasswordFile = "/var/lib/mosquitto/hass-password";
          };
          # Livegrid OpenMatrix LED panel. It publishes its own HA discovery
          # payloads under homeassistant/ and subscribes to homeassistant/status
          # to re-announce after a restart; its own state lives under livegrid/.
          # https://livegrid.github.io/mqtt/
          users.livegrid = {
            acl = [
              "readwrite livegrid/#"
              "readwrite homeassistant/#"
            ];
            hashedPasswordFile = "/var/lib/mosquitto/livegrid-password";
          };
          # Zigbee2MQTT. Its own state lives under zigbee2mqtt/; it also needs
          # homeassistant/# to publish MQTT discovery payloads for every paired
          # device and to watch homeassistant/status for HA restarts.
          users.zigbee2mqtt = {
            acl = [
              "readwrite zigbee2mqtt/#"
              "readwrite homeassistant/#"
            ];
            hashedPasswordFile = "/var/lib/mosquitto/zigbee2mqtt-password";
          };
        }
      ];
    };

    # LAN IoT devices (Livegrid panel) need to reach the broker.
    networking.firewall.allowedTCPPorts = [ 1883 ];

    # password files + retained messages
    services.borgmatic.settings.source_directories = [ "/var/lib/mosquitto" ];
  };
}
