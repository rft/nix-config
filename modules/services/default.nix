{ delib, pkgs, ... }:
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

    # Jellyfin media server
    systemd.services.jellyfin.serviceConfig = {
      ProtectHome = true;
      ProtectSystem = "strict";
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
      MemoryDenyWriteExecute = false; # Jellyfin needs JIT for transcoding
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@mount"
        "~@reboot"
        "~@swap"
      ];
      ReadWritePaths = [
        "/var/lib/jellyfin"
        "/var/cache/jellyfin"
        "/var/log/jellyfin"
      ];
    };

    # Ollama LLM inference
    systemd.services.ollama.serviceConfig = {
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = false; # LLM inference needs dynamic memory
      SystemCallArchitectures = "native";
      ReadWritePaths = [
        "/var/lib/ollama"
      ];
    };

    # Home Assistant
    systemd.services.home-assistant.serviceConfig = {
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = false; # May need device access for integrations
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = false; # Python runtime needs this
      SystemCallArchitectures = "native";
    };

    # n8n workflow automation
    systemd.services.n8n.serviceConfig = {
      ProtectHome = true;
      ProtectSystem = "strict";
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
      MemoryDenyWriteExecute = false; # Node.js V8 JIT
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@mount"
        "~@reboot"
        "~@swap"
      ];
      ReadWritePaths = [
        "/var/lib/n8n"
      ];
    };

    # Paperless document management
    systemd.services.paperless-web.serviceConfig = {
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
      MemoryDenyWriteExecute = false; # Python runtime
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@mount"
        "~@reboot"
        "~@swap"
      ];
    };

    systemd.services.paperless-scheduler.serviceConfig = {
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
      MemoryDenyWriteExecute = false; # Python runtime
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@mount"
        "~@reboot"
        "~@swap"
      ];
    };

    systemd.services.paperless-consumer.serviceConfig = {
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
      MemoryDenyWriteExecute = false; # Python runtime
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@mount"
        "~@reboot"
        "~@swap"
      ];
    };
  };
}
