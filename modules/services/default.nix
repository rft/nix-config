{ delib, pkgs, ... }:
let
  # Shared baseline for all service sandboxes
  hardenedServiceConfig = {
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RestrictNamespaces = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = false;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@mount"
      "~@reboot"
      "~@swap"
    ];
  };
in
delib.module {
  name = "services";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      borgmatic
    ];

    # Jellyfin media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Ollama LLM inference
    services.ollama = {
      enable = true;
    };

    # Home Assistant
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "America/Phoenix";
        };
        default_config = {};
      };
    };

    # n8n workflow automation
    services.n8n = {
      enable = true;
      openFirewall = true;
    };

    # Paperless document management
    services.paperless = {
      enable = true;
    };

    # ──────────────────────────────────────────────
    # Systemd service hardening
    # ──────────────────────────────────────────────

    systemd.services.jellyfin.serviceConfig = hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/var/log/jellyfin" ];
    };

    systemd.services.ollama.serviceConfig = hardenedServiceConfig // {
      ProtectSystem = "strict";
      RestrictNamespaces = false;
      ReadWritePaths = [ "/var/lib/ollama" ];
    };

    systemd.services.home-assistant.serviceConfig = hardenedServiceConfig // {
      PrivateDevices = false; # May need device access for integrations
      RestrictNamespaces = false;
    };

    systemd.services.n8n.serviceConfig = hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/n8n" ];
    };

    systemd.services.paperless-web.serviceConfig = hardenedServiceConfig;
    systemd.services.paperless-scheduler.serviceConfig = hardenedServiceConfig;
    systemd.services.paperless-consumer.serviceConfig = hardenedServiceConfig;
  };
}
