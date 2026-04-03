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

## Kasm Workspaces — Upstream Bugs and Recovery

### Known upstream nixpkgs bugs

The NixOS kasmweb module has two bugs that are patched locally in `modules/services/default.nix`:

1. **Missing tools in PATH** — The init script needs `hostname` (inetutils), `systemctl` (systemd), and `sha256sum` (coreutils) but the upstream `binPath` only includes docker, openssl, gnused, yq-go. Fixed with `systemd.services.init-kasmweb.path`.

2. **Nix store symlinks break inside Docker** — The upstream init script uses `ln -sf /nix/store/.../bin /var/lib/kasmweb/bin` (and same for `www`). Docker containers mount `/var/lib/kasmweb` as `/opt/kasm/current`, but can't follow symlinks into `/nix/store` on the host. Fixed by overriding `ExecStart` with a patched script that uses `cp -rL` (copy, dereference) instead of `ln -sf`.

**Upstream tracking:** [NixOS/nixpkgs#246884](https://github.com/NixOS/nixpkgs/issues/246884) (original package request). The PATH and symlink bugs have not been reported upstream yet.

### Default credentials

- Admin: `admin@kasm.local` / `kasmweb`
- User: `user@kasm.local` / `kasmweb`

### SSL warning

Kasm generates a self-signed certificate. Browsers will show a security warning on first visit — click through "Advanced" > "Accept the Risk".

### Recovery from bad state

If Kasm containers are broken, the DB is corrupted, or the init service keeps timing out, do a full reset:

```bash
# 1. Stop all kasm systemd services
sudo systemctl stop init-kasmweb \
  docker-kasm_agent docker-kasm_api docker-kasm_db docker-kasm_db_init \
  docker-kasm_guac docker-kasm_manager docker-kasm_redis docker-kasm_share \
  docker-kasm_proxy

# 2. Remove all kasm containers
sudo docker rm -f kasm_guac kasm_agent kasm_manager kasm_share \
  kasm_api kasm_db kasm_db_init kasm_redis kasm_proxy 2>/dev/null

# 3. Remove volume and network
sudo docker volume rm kasmweb_db 2>/dev/null
sudo docker network rm kasm_default_network 2>/dev/null

# 4. Wipe data directory (certs, configs, seed state)
sudo rm -rf /var/lib/kasmweb

# 5. Reload and restart
sudo systemctl daemon-reload
sudo systemctl start init-kasmweb &
sudo journalctl -fu init-kasmweb

# 6. Once init completes, start the proxy
sudo systemctl start docker-kasm_proxy.service
```

The init takes 2–5 minutes (DB seeding). Once complete, start the proxy and Kasm is accessible at `https://bristlecone:8443`.

If the init times out, check:
- `sudo docker ps -a` — are the containers running?
- `sudo docker logs kasm_db_init` — is the DB seeding progressing?
- `sudo ls /var/lib/kasmweb/.done_initing_data` — has seeding completed?

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
