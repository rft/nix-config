# Services Reference

All self-hosted services running on **bristlecone** (the server host).
Enabled via `myconfig.services.enable = true` in the host config.

---

## Port Map

| Service              | Port  | Protocol | Bind Address |
|----------------------|-------|----------|--------------|
| Jellyfin             | 8096  | HTTP     | 0.0.0.0      |
| Ollama               | 11434 | HTTP     | 0.0.0.0      |
| Home Assistant       | 8123  | HTTP     | 0.0.0.0      |
| n8n                  | 5678  | HTTP     | 0.0.0.0      |
| Paperless-ngx        | 28981 | HTTP     | 0.0.0.0      |
| Kasm Workspaces      | 8443  | HTTPS    | 0.0.0.0      |
| changedetection.io   | 5000  | HTTP     | 0.0.0.0      |

---

## Services

### Jellyfin

- **What:** Media server for streaming movies, TV, music, and photos.
- **Port:** 8096 (firewall opened via `openFirewall`)
- **Data:** `/var/lib/jellyfin`
- **Hardening:** Strict systemd sandbox with write access to data, cache, and log paths.

### Ollama

- **What:** Local LLM inference server.
- **Port:** 11434 (firewall opened via `openFirewall`)
- **Data:** `/var/lib/ollama`
- **Hardening:** Strict systemd sandbox with write access to data path.

### Home Assistant

- **What:** Home automation platform.
- **Port:** 8123 (firewall opened via `openFirewall`)
- **Config:** Timezone set to `America/Phoenix`, metric units.
- **Hardening:** Systemd sandbox with device access allowed for hardware integrations.

### n8n

- **What:** Workflow automation tool (open-source Zapier alternative).
- **Port:** 5678 (firewall opened via `openFirewall`)
- **Data:** `/var/lib/n8n`
- **Note:** Secure cookies disabled (`N8N_SECURE_COOKIE=false`) for non-HTTPS access.
- **Hardening:** Strict systemd sandbox with write access to data path.

### Paperless-ngx

- **What:** Document management system with OCR.
- **Port:** 28981 (firewall opened manually)
- **Hardening:** Systemd sandbox on web, scheduler, and consumer processes.

### Kasm Workspaces

- **What:** Container-based browser and desktop streaming platform.
- **Port:** 8443 HTTPS (firewall opened manually)
- **Note:** Manages its own Docker containers internally (DB, API, manager, agent, proxy). No additional systemd hardening applied.

### changedetection.io

- **What:** Website change detection, monitoring, and notification service.
- **Port:** 5000 (firewall opened manually)
- **Data:** `/var/lib/changedetection-io`
- **Note:** `behindProxy` enabled for reverse proxy setups.
- **Hardening:** Strict systemd sandbox with write access to data path.

---

## Utilities

### borgmatic

Installed as a system package for backup management. Not a running service — invoked on-demand or via cron/timer.

---

## Systemd Hardening

All services (except Kasm) share a hardened baseline:

- `ProtectHome`, `ProtectKernelTunables/Modules/Logs`, `ProtectControlGroups`, `ProtectClock`
- `NoNewPrivileges`, `PrivateTmp`, `PrivateDevices`
- `RestrictRealtime`, `RestrictSUIDSGID`, `RestrictNamespaces`
- `LockPersonality`, `SystemCallArchitectures = native`
- Syscall filter: `@system-service` minus `@mount`, `@reboot`, `@swap`

Per-service overrides add `ReadWritePaths` or relax restrictions as needed.
