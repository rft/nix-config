{ delib, lib, ... }:
delib.module {
  name = "services.zigbee2mqtt";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.zigbee2mqtt.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled = {
    # Zigbee2MQTT, driving the SONOFF Dongle Plus MG24 (Silicon Labs EFR32MG24
    # behind a CP2102N UART bridge) as the Zigbee coordinator.
    #
    # Chosen over ZHA because the Third Reality Smart Plug Gen3 (3RSP02064Z)
    # converter here exposes the full metering set plus metering_only_mode and
    # the power rise/drop thresholds; ZHA still lacks the latter two
    # (zigpy/zha-device-handlers#4844). HA needs no config change either way —
    # the mqtt component is already loaded and picks devices up via discovery.
    services.zigbee2mqtt = {
      enable = true;
      settings = {
        serial = {
          # by-id rather than /dev/ttyUSB0, which moves if another USB serial
          # device enumerates first. The module derives its DeviceAllow from
          # this path; systemd stat()s through the symlink, so it still
          # resolves to the 188:0 char device.
          port = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_2a7b2307dda2ef11902a8e6661ce3355-if00-port0";
          adapter = "ember"; # EFR32MG24 runs EmberZNet, not zstack
          baudrate = 115200; # stock SONOFF firmware; community builds use 460800
          rtscts = false;
        };
        mqtt.server = "mqtt://localhost:1883";
        # mqtt.user/password deliberately absent — they come from the
        # EnvironmentFile below rather than the world-readable store.
        frontend = {
          enabled = true;
          port = 8080;
        };
        advanced.log_level = "info";
        # homeassistant.enabled already defaults to services.home-assistant.enable.
      };
    };

    # ZIGBEE2MQTT_CONFIG_MQTT_USER / _PASSWORD override the generated YAML
    # (applyEnvironmentVariables in z2m's settings.js). systemd reads this as
    # root before dropping to the zigbee2mqtt user, so 0400 root:root is fine.
    # Created out-of-band like the mosquitto password files.
    systemd.services.zigbee2mqtt.serviceConfig.EnvironmentFile = "/var/lib/zigbee2mqtt-mqtt.env";

    # The Zigbee2MQTT frontend (pairing, device settings, map).
    networking.firewall.allowedTCPPorts = [ 8080 ];

    services.borgmatic.settings.source_directories = [
      "/var/lib/zigbee2mqtt" # coordinator state; losing it means re-pairing
      "/var/lib/zigbee2mqtt-mqtt.env"
    ];
  };
}
