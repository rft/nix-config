{ delib, pkgs, lib, ... }:
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
      host = "0.0.0.0";
      openFirewall = true;
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
      environment.N8N_SECURE_COOKIE = "false";
    };

    # Paperless document management
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
    };
    networking.firewall.allowedTCPPorts = [ 28981 ];

    # ──────────────────────────────────────────────
    # Systemd service hardening
    # ──────────────────────────────────────────────

    systemd.services.jellyfin.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      RestrictNamespaces = false;
      ReadWritePaths = [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/var/log/jellyfin" ];
    });
    systemd.services.jellyfin.environment.JELLYFIN_HttpListenerHost__BindAddresses = "0.0.0.0";
    systemd.tmpfiles.rules = [ "d /var/log/jellyfin 0750 jellyfin jellyfin -" ];

    systemd.services.ollama.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      RestrictNamespaces = false;
      ReadWritePaths = [ "/var/lib/ollama" ];
    });

    systemd.services.home-assistant.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      PrivateDevices = false; # May need device access for integrations
      RestrictNamespaces = false;
    });

    systemd.services.n8n.serviceConfig = lib.mapAttrs (_: lib.mkForce) (hardenedServiceConfig // {
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/n8n" ];
    });

    systemd.services.paperless-web.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
    systemd.services.paperless-scheduler.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
    systemd.services.paperless-consumer.serviceConfig = lib.mapAttrs (_: lib.mkForce) hardenedServiceConfig;
  };
}
