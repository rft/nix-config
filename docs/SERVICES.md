# Services Reference

All self-hosted services running on **bristlecone** (the server host).
Enabled via `myconfig.services.enable = true` in the host config. Each service is
its own module under `modules/services/` (`services.<name>`), so a single one can
also be switched on or off with `myconfig.services.<name>.enable`.

---

## Port Map

| Service              | Port  | Protocol | Reachable from |
|----------------------|-------|----------|----------------|
| Jellyfin             | 8096  | HTTP     | LAN            |
| Home Assistant       | 8123  | HTTP     | LAN            |
| Paperless-ngx        | 28981 | HTTP     | NetBird (`wt0`) only |
| changedetection.io   | 5000  | HTTP     | NetBird (`wt0`) only |
| Karakeep             | 3000  | HTTP     | NetBird (`wt0`) only |
| Actual Budget        | 5006  | HTTPS    | NetBird (`wt0`) only |
| Mosquitto (MQTT)     | 1883  | MQTT     | LAN            |
| Zigbee2MQTT frontend | 8080  | HTTP     | NetBird (`wt0`) only |
| 9router (AI gateway) | 20128 | HTTP     | NetBird (`wt0`) only |
| Hermes API server    | 8642  | HTTP     | NetBird (`wt0`) only |
| Hermes dashboard     | 9119  | HTTP     | NetBird (`wt0`) only |
| Meilisearch          | 7700  | HTTP     | localhost      |
| Karakeep browser CDP | 9222  | HTTP     | localhost      |
| Samba (scanner)      | 445   | SMB      | LAN            |
| Samba NetBIOS        | 139   | SMB      | LAN            |
| mDNS (zeroconf)      | 5353  | UDP      | LAN            |

Scanner uploads also use SFTP on port 22 (already open via `core.ssh`).

The web UIs marked NetBird-only listen on every interface but are opened in the
firewall on `wt0` alone, so reach them as `http://bristlecone.netbird.cloud:<port>`
from a machine on the mesh. Things LAN devices talk to directly (MQTT, SMB, Home
Assistant, Jellyfin) stay LAN-open.

---

## Services

### Jellyfin

- **What:** Media server for streaming movies, TV, music, and photos.
- **Port:** 8096 (firewall opened via `openFirewall`)
- **Data:** `/var/lib/jellyfin`
- **Hardening:** Strict systemd sandbox with write access to data, cache, and log paths.

### Home Assistant

- **What:** Home automation platform.
- **Port:** 8123 (firewall opened via `openFirewall`)
- **Config:** Timezone set to `America/Phoenix`, metric units.
- **Hardening:** Systemd sandbox with device access allowed for hardware integrations.
- **Discovery:** UDP 5353 is firewall-opened for mDNS. Home Assistant's zeroconf
  listener binds that port and replies arrive on it, so without the rule every
  response is dropped and nothing (AirGradient, esphome, cast) is auto-discovered.

#### AirGradient ONE monitors (I-9PSL-DE)

Two indoor monitors, handled by the native `airgradient` component in
`extraComponents`. Local polling over the device's own HTTP API once a minute —
no AirGradient cloud account and no MQTT involved.

Device firmware must be **3.1.1 or newer**, and the monitors must be joined to
the same LAN as bristlecone (192.168.12.0/24).

**Set `configurationControl` to `local` before anything else.** If a monitor is
onboarded to the AirGradient dashboard it takes its configuration from the cloud,
Home Assistant's config entities (display brightness, LED bar mode, temperature
unit, CO₂ calibration) stay read-only, and **switching cloud → local afterwards
requires a factory reset**. Set it during the device's own captive-portal setup,
or via its local web UI.

Per monitor:

1. Power it on. A fresh device raises its own AP, `airgradient-<serialnumber>`.
   Join it and use the captive portal to enter the WiFi credentials and pick
   local configuration.
2. In Home Assistant: **Settings → Devices & Services**. Each monitor should
   appear under Discovered. If not, **Add Integration → AirGradient** and enter
   its IP or `airgradient_<serialnumber>.local`.
3. Repeat for the second monitor — the integration creates one config entry per
   device, so they are added separately and get distinct entity name prefixes.

Verify a monitor is reachable from the server before adding it:

```bash
curl -s http://<monitor-ip>/measures/current | jq
```

Entities: PM1/PM2.5/PM10 plus PM0.3 particle count, CO₂, temperature, humidity,
TVOC and NOx index (and their raw values), WiFi signal strength, a firmware
update entity, and the config entities listed above.

Docs: <https://www.home-assistant.io/integrations/airgradient/>

### Mosquitto (MQTT)

- **What:** MQTT broker for Home Assistant and LAN IoT devices.
- **Port:** 1883 (firewall opened manually; unencrypted, LAN only)
- **Data:** `/var/lib/mosquitto`
- **Auth:** Anonymous access is off. Each client authenticates as a named user
  with its own ACL — there is deliberately no `pattern readwrite #` line, since
  patterns apply to every authenticated user and would nullify the per-user ACLs.

| User       | ACL                                       | Password file                        |
|------------|-------------------------------------------|--------------------------------------|
| `hass`     | `readwrite #`                             | `/var/lib/mosquitto/hass-password`   |
| `livegrid` | `readwrite livegrid/#`, `readwrite homeassistant/#` | `/var/lib/mosquitto/livegrid-password` |
| `zigbee2mqtt` | `readwrite zigbee2mqtt/#`, `readwrite homeassistant/#` | `/var/lib/mosquitto/zigbee2mqtt-password` |

Password files hold a bare `mosquitto_passwd` hash with the `username:` prefix
stripped, and are created out of band (like `smbpasswd -a scanner`). They are
passed in as systemd credentials, so **a missing file makes mosquitto fail to
start** — create it before rebuilding:

`mosquitto_passwd` only reaches `PATH` once this module is deployed, so the
first run needs a `nix shell`. Quote the flake ref under xonsh, where an
unquoted `#` starts a comment and silently truncates the argument.

```bash
nix shell 'nixpkgs#mosquitto'
# -c here is mosquitto_passwd's "create file" flag. It prompts for the
# password twice, so the password never lands in shell history.
mosquitto_passwd -c /tmp/mqtt-pw livegrid
exit

sudo sed 's/^livegrid://' /tmp/mqtt-pw \
  | sudo tee /var/lib/mosquitto/livegrid-password >/dev/null
rm /tmp/mqtt-pw
sudo nixos-rebuild switch --flake '.#bristlecone'
```

#### Livegrid OpenMatrix panel

Docs: <https://livegrid.github.io/mqtt/>. The panel publishes its own Home
Assistant discovery payloads, so nothing is declared in the Home Assistant
config — the entities (light with brightness, write-only display text,
temperature/humidity/CO₂/ambient-light/RSSI sensors) appear on their own.

In the Livegrid web app under **Settings → MQTT**:

| Field    | Value                                                   |
|----------|---------------------------------------------------------|
| Broker   | bristlecone's LAN IP (the default `homeassistant.local` will not resolve here) |
| Port     | `1883`                                                  |
| Username | `livegrid`                                              |
| Password | the one set above                                       |

Then toggle **Home Assistant Discovery** on and save.

Topics it uses:

| Purpose             | Topic                                       |
|---------------------|---------------------------------------------|
| Light discovery     | `homeassistant/light/<device_id>/light/config` |
| Text discovery      | `homeassistant/text/<device_id>/display_text/config` |
| Sensor discovery    | `homeassistant/sensor/livegrid_<sensor>/config` |
| Light command       | `livegrid/<device_id>/light/set`            |
| Light state         | `livegrid/<device_id>/light/state`          |
| Availability        | `livegrid/<device_id>/status` (`online`/`offline`) |
| Display text        | `livegrid/text` (command + echo, configurable) |
| Environment sensors | `livegrid/sensors` (configurable)           |

Light payload is JSON — `{"state":"ON","brightness":128}` — with plain
`ON`/`OFF` also accepted.

#### Bootstrap after deploy

Home Assistant's broker connection is a config entry, not YAML, so it is added
once through the UI: **Settings → Devices & Services → Add Integration → MQTT**,
broker `localhost`, port `1883`, user `hass`. Discovery is on by default there.

Verify from the server:

```bash
mosquitto_sub -h localhost -u livegrid -P '<password>' -t 'livegrid/#' -v
mosquitto_sub -h localhost -u hass -P '<password>' -t 'homeassistant/#' -v
```

### Zigbee2MQTT

- **What:** Zigbee coordinator daemon. Bridges Zigbee devices onto MQTT, where
  Home Assistant picks them up through discovery.
- **Port:** 8080 (frontend — pairing, per-device settings, network map)
- **Data:** `/var/lib/zigbee2mqtt`
- **Radio:** SONOFF Dongle Plus MG24 (Silicon Labs EFR32MG24) over USB

Nothing is declared on the Home Assistant side. The `mqtt` component is already
loaded, Zigbee2MQTT publishes discovery payloads under `homeassistant/`, and
paired devices appear on their own.

#### Why Zigbee2MQTT rather than ZHA

ZHA is built into Home Assistant and needs no broker, so it is the cheaper
option on paper. It lost on device support: for the Third Reality Smart Plug
Gen3 (`3RSP02064Z`) the Zigbee2MQTT converter exposes `metering_only_mode` and
the power rise/drop thresholds, which ZHA still lacks
([zigpy/zha-device-handlers#4844](https://github.com/zigpy/zha-device-handlers/issues/4844)).
Mosquitto was already running with Home Assistant attached, so Zigbee2MQTT
drops in as one more authenticated MQTT client rather than new infrastructure.

#### The coordinator

The dongle enumerates through a CP2102N UART bridge as `/dev/ttyUSB0`, owned
`root:dialout`. The config points at the `by-id` path instead, since `ttyUSB0`
moves if another USB serial device enumerates first:

```
/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_<serial>-if00-port0
```

The upstream module derives its systemd `DeviceAllow=` from `serial.port`.
systemd `stat()`s through the symlink, so the `by-id` path still resolves to
the `188:0` character device — verified working, no extra `DeviceAllow` entry
needed. The module also adds `dialout` as a supplementary group.

| Setting    | Value      | Why                                          |
|------------|------------|----------------------------------------------|
| `adapter`  | `ember`    | EFR32MG24 runs EmberZNet, not zstack         |
| `baudrate` | `115200`   | stock SONOFF firmware; community builds use `460800` |
| `rtscts`   | `false`    | dongle has no hardware flow control; ASH falls back to software |

A healthy start logs the firmware version. This dongle shipped **EmberZNet
7.4.5 [GA], EZSP v13**:

```
zh:ember: Adapter version info: {"ezsp":13,"revision":"7.4.5 [GA]",...}
zh:ember: [INIT TC] Adapter network matches config.
z2m: zigbee-herdsman started (resumed)
```

`Adapter EZSP protocol version (13) lower than Host. Switched.` is normal and
not an error. If the firmware ever reads **8.0.2**, expect repeated
`ASH_ERROR_TIMEOUTS` and restart loops — that is a firmware bug
([zigbee2mqtt#30891](https://github.com/Koenkk/zigbee2mqtt/issues/30891)) fixed
by reflashing, not by changing `baudrate` or `rtscts`.

#### Credentials

Two files, both created out of band, both required before the first rebuild —
and they hold the **same** password in **different formats**:

| File | Owner/mode | Contents |
|------|-----------|----------|
| `/var/lib/mosquitto/zigbee2mqtt-password` | `mosquitto:mosquitto` `0400` | bare hash, `username:` prefix stripped |
| `/var/lib/zigbee2mqtt-mqtt.env` | `root:root` `0400` | `KEY=value` env pairs |

The broker file follows the same rule as every other entry in the Mosquitto
table above. The env file exists because `services.zigbee2mqtt.settings` is
serialised into a world-readable store path, so `mqtt.user`/`mqtt.password` are
deliberately absent from it. Zigbee2MQTT's `applyEnvironmentVariables` overlays
them at startup instead:

```
ZIGBEE2MQTT_CONFIG_MQTT_USER=zigbee2mqtt
ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=<password>
```

systemd reads the `EnvironmentFile` as root before dropping to the
`zigbee2mqtt` user, so `0400 root:root` is correct.

#### Bootstrap after deploy

Generate the password once and write both files from it. Under nushell there
are no heredocs — pipe a string into `tee` and discard output with `| ignore`,
since `>` is not a redirection operator there:

```nu
let pw = (random chars --length 32)   # alphanumeric only, nothing to escape

# Broker side. `sed` strips the `username:` prefix mosquitto_passwd writes;
# leaving it in produces `zigbee2mqtt:zigbee2mqtt:$7$...` in the merged
# passwd-0 and takes the whole broker down (see Troubleshooting).
sudo mosquitto_passwd -c -b /var/lib/mosquitto/zigbee2mqtt-password zigbee2mqtt $pw
sudo sed -i 's/^zigbee2mqtt://' /var/lib/mosquitto/zigbee2mqtt-password
sudo chown mosquitto:mosquitto /var/lib/mosquitto/zigbee2mqtt-password
sudo chmod 400 /var/lib/mosquitto/zigbee2mqtt-password

# Client side
$"ZIGBEE2MQTT_CONFIG_MQTT_USER=zigbee2mqtt\nZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=($pw)\n" | sudo tee /var/lib/zigbee2mqtt-mqtt.env | ignore
sudo chmod 400 /var/lib/zigbee2mqtt-mqtt.env

sudo nixos-rebuild switch --flake '.#bristlecone'
```

Confirm every password file is hash-only before rebuilding, without printing
any hashes:

```nu
sudo awk '{print FILENAME": "(($0 ~ /^\$7\$/) ? "OK (hash only)" : "BAD (username prefix)")}' /var/lib/mosquitto/*-password
```

#### Pairing devices

`permit_join` is `false` in the config; join is opened from the frontend at
`http://bristlecone.netbird.cloud:8080` (**Permit join**, 3-minute window), never by editing
the Nix. Paired devices are written to `devices.yaml` / `groups.yaml` in the
data dir, which are separate from the `configuration.yaml` that the unit's
`ExecStartPre` recopies from the store on every start — so pairings survive
rebuilds and restarts. The network itself is backed up to
`coordinator_backup.json`.

**Third Reality Smart Plug Gen3 (`3RSP02064Z`)** — hold the On/Off button for
more than 10 seconds until the LED flashes red. A factory-fresh plug enters
pairing mode on first insertion without the button hold. Exposes on/off, power,
energy, voltage, current, AC frequency, power factor, LED brightness, countdown
timers, `metering_only_mode`, and `reset_total_energy`.

> **Gotcha:** by default these plugs only report instantaneous watts about once
> a minute. Set **power rise threshold** and **power drop threshold** to `1` (W)
> per plug for near-real-time updates. The `energy` (kWh) sensor feeds Home
> Assistant's Energy dashboard directly.

#### Troubleshooting

**`MQTT failed to connect, exiting... ()`** — empty parentheses mean the broker
refused the connection. Check that mosquitto is actually up first (a broken
password file takes it down entirely), then that both credential files carry
the same password.

**`password-file: Error: Unable to decode line in password file
'/var/lib/mosquitto/passwd-0'`** — a `hashedPasswordFile` still has its
`username:` prefix. This kills mosquitto for *all* clients, so Home Assistant
and Livegrid go down with it. Strip the prefix, then note that mosquitto will
have hit its restart limit and needs `reset-failed` before it will start:

```nu
sudo sed -i 's/^zigbee2mqtt://' /var/lib/mosquitto/zigbee2mqtt-password
sudo systemctl reset-failed mosquitto
sudo systemctl restart mosquitto
sudo systemctl reset-failed zigbee2mqtt
sudo systemctl restart zigbee2mqtt
```

**Nothing listening on 8080** — the frontend binds late, after the MQTT
connection succeeds. An unreachable port almost always means the service is
crash-looping earlier; read `journalctl -u zigbee2mqtt` rather than debugging
the port.

**`Permission denied` opening the serial device** — `DeviceAllow` failed to
resolve the `by-id` symlink. Append the real node; `serviceConfig` list options
merge, so this adds to upstream's entry rather than replacing it:

```nix
systemd.services.zigbee2mqtt.serviceConfig.DeviceAllow = [ "/dev/ttyUSB0" ];
```

### Paperless-ngx

- **What:** Document management system with OCR.
- **Port:** 28981 (firewall: `wt0` only)
- **Data:** `/var/lib/paperless` (documents in `media/`)
- **Consume dir:** `/var/lib/scan/consume` — *not* the default `/var/lib/paperless/consume`. See [Document scanning](#document-scanning) for why.
- **Settings:** `PAPERLESS_OCR_LANGUAGE=eng`, recursive consume, subdirectories as tags.
- **Hardening:** Systemd sandbox on web, scheduler, and consumer processes.

### changedetection.io

- **What:** Website change detection, monitoring, and notification service.
- **Port:** 5000 (firewall: `wt0` only)
- **Data:** `/var/lib/changedetection-io`
- **Note:** `behindProxy` enabled for reverse proxy setups.
- **Hardening:** Strict systemd sandbox with write access to data path.

### Karakeep

- **What:** Self-hosted bookmark / read-it-later app (formerly Hoarder).
- **Port:** 3000 (firewall: `wt0` only)
- **Data:** `/var/lib/karakeep` (SQLite)
- **Units:** `karakeep-init` (oneshot: secret generation + DB migration), `karakeep-web`,
  `karakeep-workers`, `karakeep-browser`. There is **no** umbrella `karakeep.service` —
  the units' `partOf = [ "karakeep.service" ]` is a dangling reference upstream, so
  `systemctl restart karakeep` fails. Restart the units individually.
- **Dependencies:** Meilisearch on 127.0.0.1:7700 (full-text search) and a headless
  chromium on 127.0.0.1:9222 (screenshots / archiving), both auto-enabled by the module.
  Workers get `monolith` and `yt-dlp` on PATH for page and video archiving.
- **Secrets:** `MEILI_MASTER_KEY` and `NEXTAUTH_SECRET` are generated by `karakeep-init`
  into `/var/lib/karakeep/settings.env` on first boot — not managed through Nix. Deleting
  that file invalidates all sessions.
- **Note:** Meilisearch runs unauthenticated on loopback; the module hands Karakeep a
  master key the server ignores. Fine while it stays on 127.0.0.1.
- **Note:** `NEXTAUTH_URL` is pinned to `http://bristlecone.netbird.cloud:3000` — update it if the host
  is reached under a different name, or sign-in redirects break.
- **Hardening:** Strict systemd sandbox on web and workers with write access to the data
  path. `karakeep-init` and `karakeep-browser` are left as upstream ships them (the
  browser is already sandboxed more strictly). `karakeep-web` also sets `NEXT_CACHE_DIR`
  explicitly: 26.05's karakeep module tries to set it, but writes
  `environment = { NEXT_CACHE_DIR = ...; } // karakeepEnv;` where `karakeepEnv` is a
  `lib.mkMerge` value, so the merged attrset carries `_type = "merge"` and the module
  system keeps only `contents`, silently dropping the variable. `CacheDirectory` does
  come from upstream and is no longer set here.
- **AI tagging:** Inference goes through the local 9router gateway
  (`OPENAI_BASE_URL = http://127.0.0.1:20128/v1`, model `cx/gpt-5.6-luna` for text and
  images, plain JSON output because 9router drops `json_schema`). Karakeep decides
  whether inference is configured from `OPENAI_API_KEY` alone, so until that key exists
  nothing is tagged and the workers log nothing about it. 9router requires an API key
  even on loopback. Embedding auto-indexing is pinned off, because 9router serves no
  embedding models. To switch tagging on:

  1. In the 9router dashboard (`http://bristlecone.netbird.cloud:20128`), create an API
     key for Karakeep.
  2. Append it. `karakeep-init` never overwrites this file:

     ```bash
     echo 'OPENAI_API_KEY=<9router key>' | sudo tee -a /var/lib/karakeep/settings.env
     sudo systemctl restart karakeep-web karakeep-workers
     ```

  3. Save a link, then watch `journalctl -u karakeep-workers -f` for the `[inference]`
     job. Bookmarks saved before the key existed are not re-tagged on their own.

### Actual Budget

- **What:** Local-first personal finance / envelope budgeting. The server syncs budget
  files between the web UI, the desktop app and phones; every client keeps a full copy.
- **Port:** 5006, HTTPS (firewall: `wt0` only). Upstream's default is 3000, which
  Karakeep holds.
- **URL:** `https://bristlecone.netbird.cloud:5006`
- **Data:** `/var/lib/private/actual` (`DynamicUser`; `/var/lib/actual` is a symlink).
  `server-files/account.sqlite` holds the server password hash and file registry,
  `user-files/` the budgets.
- **TLS:** The web client needs `SharedArrayBuffer`, which browsers only expose in a
  secure context, so plain `http://` works on localhost and nowhere else. There is no
  reverse proxy, so Actual serves HTTPS itself from a self-signed cert that the unit's
  `preStart` generates into `/var/lib/actual/tls/` (P-256, CN/SAN
  `bristlecone.netbird.cloud`, 825 days — Apple's ceiling for TLS certs, even from
  user-trusted roots). It is regenerated when within 30 days of expiry, after which
  each device has to trust the new one.
- **Hardening:** Upstream's unit as shipped — it is already stricter than the shared
  baseline (`DynamicUser`, `PrivateUsers`, empty `CapabilityBoundingSet`,
  `ProtectProc=invisible`), and forcing the baseline's `SystemCallFilter` would drop
  the `@pkey` group V8 needs.

#### Bootstrap after deploy

1. Fetch the cert on each device that will open the web UI. NetBird already
   authenticates the peer, so pulling it off the live port is safe:

   ```bash
   openssl s_client -connect bristlecone.netbird.cloud:5006 </dev/null 2>/dev/null \
     | openssl x509 > bristlecone-actual.pem
   ```

2. Trust it:
   - **macOS:** `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain bristlecone-actual.pem`
   - **iOS:** AirDrop the file, install the profile in Settings, then enable it under
     **General → About → Certificate Trust Settings**.
   - **NixOS:** add it to `security.pki.certificateFiles`. Firefox keeps its own store —
     import it under **Settings → Privacy & Security → Certificates**.
3. Open `https://bristlecone.netbird.cloud:5006` and set the server password. The first
   visitor sets it, so do this straight after the first deploy.

Check the cert from the server with
`sudo openssl x509 -in /var/lib/actual/tls/cert.pem -noout -subject -enddate`.

The unit's `ExecStartPost` also copies the cert to `/var/lib/actual-cert/cert.pem`
(world-readable). Clients on this host trust that copy, because the original sits in the
DynamicUser's `0700` directory. The Hermes `actual` MCP server is one such client.

### 9router

- **What:** Shared AI gateway, so provider logins, OAuth refresh, and quota tracking
  live in one place. Agents on the other hosts point their Anthropic/OpenAI base URLs
  at it over Netbird.
- **Port:** 20128, opened only on the Netbird interface (`wt0`). The dashboard login
  defaults to `123456` and `/v1` needs no API key until one is required in the
  dashboard, so keep it off the LAN.
- **Data:** `/var/lib/9router` (`DynamicUser`, mode `0700`)
- **Unit:** `9router` runs the bundled Next.js server (`custom-server.js`) directly
  rather than the interactive `9router` CLI, which detaches and npm-installs deps
  into `$HOME` at startup.
- **Hardening:** Shared baseline plus `ProtectSystem = strict`.

### Hermes Agent

- **What:** [Hermes Agent](https://hermes-agent.nousresearch.com/) (Nous Research) as an
  always-on messaging gateway: talk to it from Telegram, Discord, Slack, etc., and its
  cron jobs run here. Upstream's NixOS module (`inputs.hermes-agent`) does the work.
  This repo's module sets the paths, model, hardening and backups.
- **Ports:** 9119 (`wt0` only), the web dashboard (see **Dashboard and Memory Wiki**).
  8642 (`wt0` only) is open too, but listens only once the API server platform is
  switched on. The messaging side only dials out, to bot APIs and the model endpoint.
- **Units:** `hermes-agent` (the gateway: messaging, cron, MCP servers) and
  `hermes-backend` (`hermes dashboard`), both on one `HERMES_HOME`, with the same
  sandbox.
- **Data:** `/var/lib/hermes` (user/group `hermes`, `2770`). `HERMES_HOME` is
  `/var/lib/hermes/.hermes` (`config.yaml`, `.env`, `state.db` sessions, memories,
  skills), and the agent's working directory is `/var/lib/hermes/workspace`.
- **Projects:** the agent can read *and* write `/srv/projects`, and run things there.
  That takes three grants, because any one of them alone leaves it blocked:
  `ReadWritePaths` (`ProtectSystem=strict` makes everything else read-only), a
  recursive `A+` ACL giving the `hermes` group `rwx` plus a default entry so new repos
  inherit it (the tree is `0755` `nano`:`users` and the agent is neither), and the exec
  bind mount the host already sets up. `/srv/projects` is `2770` rather than `0750`
  because the group bits of an ACL-bearing directory are its mask, and an `r-x` mask
  would clamp the ACL back to read-only. `GIT_CONFIG_SYSTEM` adds
  `safe.directory=/srv/projects/*` for this service only — without it every `git`
  command in the login user's repos fails with *detected dubious ownership*. The file
  `include`s nix-mineral's `/etc/gitconfig` so its hardening still applies. Commit
  identity is not set: `sudo -u hermes -H git config --global user.name …` if you want
  the agent to commit. **This is a broad grant** — an agent that runs arbitrary tools
  now has write access to every repo on the host. Narrow `projectsDir` in the module to
  a single directory if that's too much.
- **Model:** `cx/gpt-6.1-sol` through the 9router gateway on this host
  (`http://127.0.0.1:20128/v1`, provider `9router`). Its dashboard has API-key auth
  turned on, so `NINEROUTER_API_KEY` in the env file is **required** — loopback is not
  exempt. Without it the gateway logs `key_env NINEROUTER_API_KEY is set but the
  variable is empty/unset` and every inference call returns `Missing API key`; mint a
  key in the dashboard at `http://bristlecone.netbird.cloud:20128`. Change the model in
  `settings.model.default` in `modules/services/hermes-agent.nix`. `/v1/models` needs
  no key, so `curl -s http://127.0.0.1:20128/v1/models | jq -r '.data[].id'` still
  lists what 9router offers from bristlecone.
- **CLI:** `addToSystemPackages` puts the service's own `hermes` on the PATH (it wins
  over core's `llm-agents` build with `hiPrio`) and exports `HERMES_HOME`, so
  `hermes` in a shell reads the gateway's own config and state. Nix manages
  `config.yaml`, so the CLI refuses to change settings that Nix owns and tells you to
  rebuild instead.
- **Interactive chat:** run it as the service user — `sudo -u hermes -H hermes chat`
  (`-H` sets `HOME=/var/lib/hermes`, so `HERMES_HOME` resolves on its own). Anything
  that goes through the gateway control path (`chat`, `gateway attach`, native/TUI
  clients) is refused for any other user: `gateway_runtime_discovery` requires that the
  caller's uid own `HERMES_HOME`, and that the home not be group-writable by anyone but
  the owner, while upstream's tmpfiles rules force `2770`. Nor do the read-only
  commands: `2770 hermes:hermes` shuts the login user out of the directory entirely, so
  even `hermes status` dies with `PermissionError` on `.hermes/.container-mode` before
  it parses arguments. Every `hermes` command on this host goes through
  `sudo -u hermes -H`. This is why the login user is *not* in the `hermes` group — see
  the comment in the module.
- **Telemetry:** `settings` answers upstream's shared-metrics consent prompt
  (opted out). Without an answer in `config.yaml`, an interactive `hermes chat` stops
  on a full-screen question and looks like it has hung. The gateway never asks.
- **Hardening:** Applied to both units: the shared baseline minus `SystemCallFilter`,
  `RestrictNamespaces`, `ProtectKernelTunables` and `ProtectKernelLogs`. The agent runs
  whatever tools it installs, and bubblewrap and Chromium's sandbox need user
  namespaces. The two `ProtectKernel*` options overmount `/proc/sys` and `/proc/kmsg`.
  While a locked overmount like that exists, the kernel refuses a fresh procfs mount in
  a user namespace, so bwrap would fail with `Can't mount proc on /proc: Operation not
  permitted`. Turning them off costs little: the agent isn't root, so `/proc/sys` stays
  read-only and `/proc/kmsg` unreadable to it. `ProtectHome` is forced on over
  upstream's `false`, because the agent's `HOME` is `/var/lib/hermes`. `MemoryMax=24G`
  caps each unit; it stands in for bubblewrap's per-command memory limit, which is off
  (see **Terminal sandbox**). nix-mineral mounts `/var` noexec, so `/var/lib/hermes`
  gets an exec bind mount (like `/srv/projects`). Without it, the `pip --user` /
  `uv tool` / `npm -g` installs in its `HOME` and the scripts in its workspace could
  not run.
- **Terminal sandbox:** `terminal.backend = "bubblewrap"` (official `bubblewrap`
  plugin). Every `terminal` and `execute_code` command runs in its own `bwrap` sandbox:
  - the host root read-only at the same paths, and the working directory writable
  - `/srv/projects` bound read-write, `/srv/share` read-only
  - the dot entries of `HOME` and all of `HERMES_HOME` (`.env`, `auth.json`,
    `state.db`) hidden
  - private `/tmp`, `/proc` and `/dev`, and no agent or D-Bus sockets

  Profile `network` keeps the host network, so it can still clone and install. The
  per-command `RLIMIT_AS` / `RLIMIT_CPU` limits are set to `0` (off). Their defaults
  (256 MB, 30 s) break pip, node and any build, and address-space limits break the JVM
  and V8 long before real memory runs out. `max_procs` is 2048. Approvals apply
  unchanged on top. Commands are never run unsandboxed: if `bwrap` or its probe fails,
  the terminal tool returns an error.
- **Plugin version gate:** upstream's flake builds `main` without passing `version`,
  so the package stamps the placeholder `0.0.0`. That fails every plugin's
  `requires_hermes` floor, and the plugin is skipped at load with `requires hermes
  >=0.21.5, running 0.0.0`. Before this module overrode it, this applied to every
  catalog plugin here, Home Assistant included. The module builds the package with
  `version = "unknown"`. An unparseable version passes the gate, which matches
  upstream's pending fix (NousResearch/hermes-agent#146654, for #144616 / #150066). The
  banner shows `vunknown` as a result. Drop the override once that PR is merged.
- **Updating:** `inputs.hermes-agent` tracks upstream `main` (upstream's own Nix
  instructions do the same; its release tags are not kept current). The weekly lock PR
  bumps it, and bristlecone builds the package itself (about 2 min), because no binary
  cache serves it.

#### Bootstrap after deploy

1. Write the secrets file. It is read on activation and merged into `.env`:

   ```bash
   sudo install -m 0640 -o hermes -g hermes /dev/null /var/lib/hermes/env
   sudoedit /var/lib/hermes/env
   ```

   Put one `KEY=value` per line:

   - `NINEROUTER_API_KEY=…` — required, or no model call succeeds (see **Model** above).
   - Each messaging platform's token, e.g. `TELEGRAM_BOT_TOKEN=…` plus
     `TELEGRAM_ALLOWED_USERS=<your id>` so only you can talk to it. See upstream's
     messaging docs for each platform's variables. With none of these set the gateway
     starts and logs `No messaging platforms enabled` — it runs cron jobs but nothing
     can reach it except the local CLI.
   - `HASS_TOKEN=…`: Home Assistant access, see **Home Assistant** below.
   - `PAPERLESS_TOKEN=…`, `KARAKEEP_API_KEY=…`, `CHANGEDETECTION_API_KEY=…`: see
     **Self-hosted service tools** below.
   - `ACTUAL_PASSWORD=…`, `ACTUAL_BUDGET_SYNC_ID=…`: see **Actual Budget (MCP)**.
   - `HERMES_DASHBOARD_BASIC_AUTH_*`: see **Dashboard and Memory Wiki**.
   - `HERMES_LANGFUSE_PUBLIC_KEY` / `_SECRET_KEY`: see **Langfuse**.
2. Re-run activation to merge the file, then restart the gateway:
   `sudo /run/current-system/activate && sudo systemctl restart hermes-agent hermes-backend`.
   Do the same after every later edit of the env file.
3. Check it with `journalctl -u hermes-agent -f` and `hermes status`. Every plugin
   should load: `journalctl -u hermes-agent | grep -i "skipped"` should print nothing
   about `bubblewrap`, `homelab`, `langfuse`, `mcp-serve`, `memory-wiki` or
   `homeassistant`. Ask the agent to run a command (from Telegram, say: "run `uname -a`
   and `ls /var/lib/hermes/.hermes`"). The first should work, and the second should
   fail because the sandbox hides `HERMES_HOME`. That confirms the bwrap sandbox works
   inside the unit.

The first OAuth login for an MCP server prints its URL to the journal instead of
opening a browser. Run that flow once from a shell (`hermes mcp add … --auth oauth`),
and the token persists in `HERMES_HOME`.

#### Home Assistant

With `services.home-assistant` on the same host, the module installs Nous Research's
official `homeassistant` plugin (from `inputs.hermes-official-plugins`, linked as
`plugins/nix-managed-homeassistant`), lists it in `plugins.enabled`, and sets
`HASS_URL=http://127.0.0.1:8123`. The plugin adds:

- **Tools:** `ha_list_entities`, `ha_get_state`, `ha_list_services`, `ha_call_service`,
  so "turn off the living room lights" works from Telegram, the API server or the CLI.
  The plugin refuses `shell_command`, `command_line`, `python_script`, `pyscript`,
  `hassio` and `rest_command`. Anything else the HA user can do, the agent can do,
  and `approvals` does not cover these calls (they are not shell commands).
- **A gateway platform:** agent replies and cron `deliver: homeassistant:<notify target>`
  show up in HA (persistent notifications, or `notify.<target>`, e.g. a phone's
  `mobile_app_*`). Inbound state changes are **off**: without
  `platforms.homeassistant.extra.watch_domains` / `watch_entities` the adapter logs a
  warning at startup and drops every event. Each forwarded event is an agent turn (a
  model call), so add a narrow filter in the module's `settings` before turning that on.

Setup, once:

1. In Home Assistant, create a dedicated non-admin user (e.g. `hermes`) so the token
   cannot change HA's own configuration, log in as it, and under **Profile →
   Security → Long-lived access tokens** create a token.
2. Add `HASS_TOKEN=<token>` to `/var/lib/hermes/env`, then
   `sudo /run/current-system/activate && sudo systemctl restart hermes-agent`.
3. Check it: `journalctl -u hermes-agent | grep -i "home assistant"`, and
   `sudo -u hermes -H hermes chat` → "list my lights".

Optional env-file limits: `HASS_ENTITY_ALLOWLIST` / `HASS_ENTITY_DENYLIST`
(comma-separated globs such as `light.*,climate.*`) restrict which entities the tools
can see and control; `HASS_HOME_CHANNEL=mobile_app_<phone>` is the target for a bare
`deliver: homeassistant`.

The module also lists `homeassistant` and `langfuse` in `_left_core_installed` in
`config.yaml`. Both used to be built into Hermes, and the migration that moved them out
looks for exactly `plugins/<name>`. It misses the Nix-managed links and would warn on
every start, and it would try to install a second copy from the catalog.

#### Self-hosted service tools

The `homelab` plugin (`packages/hermes-homelab`, this repo's own) gives the agent tools
for the other services on this host. It calls their REST APIs from the gateway process
rather than from a shell, so the tokens never reach the bwrap sandbox. A service's tools
stay hidden until its token is in the env file.

| Tools | Service | Access |
|-------|---------|--------|
| `paperless_search`, `paperless_get_document` | Paperless-ngx (full-text search over OCR text, then a document's text and metadata) | read only |
| `karakeep_search`, `karakeep_get_bookmark`, `karakeep_add` | Karakeep (search, read the archived page, save a link or note with tags) | add, never edit or delete |
| `changedetection_list_watches`, `changedetection_get_changes`, `changedetection_add_watch` | changedetection.io (watches by last change, the latest diff, add a watch) | add, never edit or delete |
| `server_health` | systemd and borgmatic (failed units, last backup result and time, disk, load) | read only, no token |

Tokens, each from a dedicated account where the app supports one:

- **Paperless:** create a non-admin user `hermes` with view permission on documents,
  then log in as it. **Profile → API Auth Token** gives `PAPERLESS_TOKEN`. Its
  permissions bound what the agent can read. Paperless's object permissions apply as
  well: a document owned by your own user is visible to `hermes` only if shared with it
  (per document, or for new uploads through **Settings → Permissions → default
  permissions** or a workflow).
- **Karakeep:** **Settings → API Keys** gives `KARAKEEP_API_KEY`. Keys belong to a user,
  and bookmarks the agent saves land in that user's library.
- **changedetection.io:** **Settings → API** gives `CHANGEDETECTION_API_KEY`. The key
  covers the whole instance.

URLs default to loopback (`PAPERLESS_URL`, `KARAKEEP_URL`, `CHANGEDETECTION_URL` override
them). Karakeep page text and changedetection diffs are third-party web content, and the
tool descriptions tell the model to treat instructions inside them as data. Hermes's
webhook platform could push changedetection alerts in automatically, but it requires
HMAC-signed requests, which changedetection's notifications can't send, and it would put
untrusted page text straight into the agent's turns. So changes are pulled with the
tools instead. A cron job does the same job:

```bash
sudo -u hermes -H hermes cron create --name daily-health --deliver telegram "0 8 * * *" \
  "Call server_health and changedetection_list_watches(unviewed_only=true). Message me only if something failed, the last backup is not a success from the last 26 hours, a disk is above 90%, or a watch has unseen changes (summarise each with changedetection_get_changes)."
```

#### Actual Budget (MCP)

Actual has no REST API. The `@actual-app/api` library downloads the budget and works on
a local copy. `packages/actual-mcp` packages the `actual-mcp` server, which wraps that
library, and the module registers it as the `actual` MCP server. It is read-only (it
runs without `--enable-write`), with these tools:

- `get-transactions`, `get-accounts`, `balance-history`
- `spending-by-category`, `monthly-summary`
- `get-grouped-categories`, `get-payees`, `get-rules`

- **Env file:** `ACTUAL_PASSWORD=<server password>` and
  `ACTUAL_BUDGET_SYNC_ID=<Sync ID>`. The Sync ID is under **Settings → Show advanced
  settings → Sync ID** in the Actual web UI. If the budget is end-to-end encrypted, also
  add `ACTUAL_BUDGET_ENCRYPTION_PASSWORD`. The MCP config refers to these as `${VAR}`,
  so nothing secret is in Nix or `config.yaml`.
- **TLS:** the server is reached as `https://bristlecone.netbird.cloud:5006`, because
  the self-signed cert names only that host. `NODE_EXTRA_CA_CERTS` points at the public
  copy in `/var/lib/actual-cert/cert.pem`.
- **Cache:** `/var/lib/hermes/actual-mcp` holds the downloaded budget. It is excluded
  from Hermes's backup, because Actual's own backup covers the budget.
- **Version lock:** each `actual-mcp` release pins one exact `@actual-app/api`. A newer
  one migrates the budget file past what the server's web client can open. The module
  asserts that `actual-mcp`'s API version equals `services.actual.package.version`. When
  a nixpkgs bump moves Actual, eval fails until `packages/actual-mcp` moves to the
  release that pins the same version (`npm view actual-mcp versions` and each version's
  `dependencies`). Update the tag, `hash` and `npmDepsHash` (`prefetch-npm-deps
  package-lock.json`).

#### Langfuse

The official `langfuse` plugin traces each turn, LLM call (tokens, cost) and tool call.
It does nothing until keys are set, logging one warning.

- **Langfuse Cloud:** create a project at <https://cloud.langfuse.com> and add
  `HERMES_LANGFUSE_PUBLIC_KEY=pk-lf-…` and `HERMES_LANGFUSE_SECRET_KEY=sk-lf-…`.
- **Self-hosted:** also add `HERMES_LANGFUSE_BASE_URL=…`. Langfuse v3 needs Postgres,
  ClickHouse, Redis and S3-compatible storage, and nixpkgs has no module for it, so it
  is not set up here.
- **Capture:** `HERMES_LANGFUSE_CAPTURE=metadata` is set in Nix, so only structure,
  tokens, cost and timing are exported, with no prompts, replies or tool content. The
  agent handles documents, budgets and home state. To export redacted content instead,
  set `HERMES_LANGFUSE_CAPTURE=sanitized` in the env file, which overrides the Nix
  value.
- **SDK:** the plugin pins `langfuse==4.15.2`. The module builds that version with
  Hermes's own Python and adds only it and `backoff` to the venv. Upstream refuses an
  `extraPythonPackages` closure that repeats a venv package, and the venv already has
  httpx, pydantic, wrapt and the OpenTelemetry SDK.

#### Dashboard and Memory Wiki

`backend.mode = "dashboard"` runs `hermes dashboard` as `hermes-backend` on
`bristlecone.netbird.cloud:9119` (`wt0` only). It is also the backend Hermes Desktop
connects to. The official `memory-wiki` plugin adds a **Memory Wiki** tab: subject pages
and daily logs derived from `state.db`, and a read-only view of `MEMORY.md` /
`USER.md`. It makes no LLM calls and no writes.

- **Auth:** binding to a non-loopback address turns on the auth gate. Add credentials
  to the env file:

  ```
  HERMES_DASHBOARD_BASIC_AUTH_USERNAME=nano
  HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=<strong password>
  HERMES_DASHBOARD_BASIC_AUTH_SECRET=<openssl rand -base64 32>
  ```

  The secret keeps sessions valid across restarts.
  `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD_HASH` (scrypt) can replace the plaintext
  password. Signed in, the dashboard can edit config and open a terminal as the agent,
  so treat this password like SSH access.
- **URL:** open it by name, as `http://bristlecone.netbird.cloud:9119`. The server
  rejects any other `Host` header (a DNS-rebinding defence).
- **Desktop app:** for the native Memory Wiki page in Hermes Desktop, copy the plugin's
  `desktop/plugin.js` to `$HERMES_HOME/desktop-plugins/memory-wiki/plugin.js` on the
  client, then enable it under **Capabilities → Plugins**.

#### MCP serve

The official `mcp-serve` plugin turns Hermes into an MCP server, over stdio only. MCP
clients such as Claude Code, Cursor and Codex can list and read the agent's
conversations, wait for new messages, send through its platforms and answer approval
prompts. With `--tools`, they also get Hermes's web, vision, image and TTS tools. Its
terminal, file and code tools are never exposed.

It has to run as `hermes`, and sudo can't prompt over a non-interactive SSH session.
So the module installs a `hermes-mcp-serve` wrapper plus a sudo rule letting the login
user run exactly `hermes mcp-serve` and `hermes mcp-serve --tools` as `hermes` without a
password. From a desktop with SSH key access to bristlecone:

```bash
claude mcp add hermes -- ssh bristlecone hermes-mcp-serve
# or, with Hermes's own tools as well:
claude mcp add hermes -- ssh bristlecone hermes-mcp-serve --tools
```

Claude Code's MCP config stays outside Nix (`~/.claude.json` must stay writable).
Reading conversations works without the gateway. `messages_send` needs the gateway
running.

#### The API server

Switched on from the env file; the module supplies the firewall port and
`approvals.unattended_mode`.

```
API_SERVER_ENABLED=true
API_SERVER_KEY=<32+ hex chars>
API_SERVER_HOST=0.0.0.0
API_SERVER_MODEL_NAME=openclaw
```

- `API_SERVER_KEY` is mandatory and must be at least 16 characters — the platform
  refuses to start without a usable one, loopback included. `openssl rand -hex 32`.
- `API_SERVER_HOST` defaults to `127.0.0.1`. `0.0.0.0` plus the `wt0`-only firewall
  rule is the same pattern as the other web UIs here; the key is the actual
  authentication either way.
- `API_SERVER_PORT` defaults to 8642, which is what the module opens. **Do not reuse
  8765** — that is the Codex app-server port and the `glasses-platform` plugin's
  listener.
- `API_SERVER_MODEL_NAME` is the name advertised on `/v1/models`, defaulting to the
  profile name. Set it to whatever the client insists on sending: an Even Realities G2
  hard-codes `openclaw`, so matching it here avoids needing a model mapping in front.
- Approval prompts have no answer channel on this platform, so
  `approvals.unattended_mode` in the module decides. It is `deny`: `mode = "smart"`
  still auto-approves low-risk commands, so the assistant works, but a dangerous one is
  refused rather than run unsupervised. Relevant now that the agent can write to
  `/srv/projects` — see the **Projects** bullet.

Check it from a mesh machine:

```bash
curl -s http://bristlecone.netbird.cloud:8642/v1/models \
  -H "Authorization: Bearer $API_SERVER_KEY" | jq -r '.data[].id'
```

For an **Even Realities G2**: the setting is Settings → Even AI → Agent Configuration,
and it is **only visible to EvenHub developers** — Even's own bring-your-own-agent
tutorial states the prerequisite outright. Accounts are made in the Even Realities phone
app (the web hub has no sign-up flow); logging in at `hub.evenrealities.com/login` with
those same credentials is what turns the account into a developer account and unlocks
Developer Mode in the phone app. Older Even wording mentions waiting for approval, newer
quickstart docs describe a plain login, so expect one or the other.

Once the menu is there, give it the *full* endpoint path — the app appends nothing, so a
bare `/v1` yields `POST /v1` and a 404 — then **Save & Activate** (saving alone does not
select the agent):

```
Endpoint: http://bristlecone.netbird.cloud:8642/v1/chat/completions
API Key:  <API_SERVER_KEY>
```

The phone makes the HTTP calls (the glasses only speak BLE to it), so the phone has to be
on the NetBird mesh — the equivalent of the LAN or Tailscale setup Even's tutorial
describes. Even warns against exposing a bring-your-own-agent endpoint to the public
internet, which the `wt0`-only firewall rule already satisfies.

Even's first-party example backend is OpenClaw, which is why the app hard-codes
`model: "openclaw"` and why `API_SERVER_MODEL_NAME=openclaw` above makes a translating
proxy unnecessary. The display truncates at roughly 400–500 characters and renders no
markdown, so either tell the agent to answer in short plain text (a rule or the system
prompt) or put the `even-g2-agent-adapter` in front, which strips markdown and truncates
on a sentence boundary with a configurable `CHAR_BUDGET`. The app never requests
streaming, and its client timeout is 300 s.

#### Reaching it from another machine

In rough order of effort:

1. **A messaging platform** — what the gateway is for. Add the platform's token to the
   env file and any device running that client (phone, laptop, another host) talks to
   the agent with nothing opened in the firewall, because the gateway dials out to the
   bot API. This is the intended path.
2. **SSH, then the local CLI** — `ssh bristlecone` and `sudo -u hermes -H hermes chat`.
   Works from any mesh machine today with no config at all; the session lands in the
   same `state.db` as everything else.
3. **The OpenAI-compatible API server** — the `api_server` platform turns the gateway
   into an OpenAI-shaped endpoint (`/v1/chat/completions`, `/v1/responses`, `/v1/runs`)
   that frontends like Open WebUI, smart glasses, and other Hermes gateways via
   `hermes peer`, can talk to. Port 8642 is already open on `wt0`; the rest is the env
   file — see **The API server** below. From another Hermes host:
   `hermes peer add bristlecone --url http://bristlecone.netbird.cloud:8642 --key <token>`,
   then `hermes peer dm bristlecone "…"`.
4. **The web dashboard:** `http://bristlecone.netbird.cloud:9119`, which is also the
   backend for Hermes Desktop. See **Dashboard and Memory Wiki** above.
5. **An MCP client:** `ssh bristlecone hermes-mcp-serve`. See **MCP serve** above.

---

## Document scanning

A Brother ADS-1700W feeds Paperless. It is a *push* scanner — it uploads finished
PDFs from its own touchscreen, so there is no SANE driver or scanner daemon on
bristlecone. Two transports are configured so a firmware incompatibility on one
doesn't block the workflow.

### Directory layout

```
/var/lib/scan                  root:root 0755   ← sshd ChrootDirectory
/var/lib/scan/consume          0777             ← PAPERLESS_CONSUMPTION_DIR
/var/lib/scan/consume/receipts 0777             ← one subdir per scanner profile
/var/lib/scan/consume/tax      0777
/var/lib/scan/consume/manuals  0777
```

The consume dir sits under `/var/lib/scan` rather than `/var/lib/paperless`
because sshd refuses to chroot into a directory it doesn't own, and
`/var/lib/paperless` belongs to the `paperless` user. Upstream's paperless module
derives `ReadWritePaths` from the `consumptionDir` option, so the relocation needs
no change to the hardening block.

With `PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS`, each subdirectory name becomes a tag on
ingest, and paperless creates any tag that doesn't exist yet. The tag is applied
unconditionally from the path — nothing inspects the document — so a file dropped
in `receipts/` is tagged `receipts` whether or not it is one. Nested directories
apply multiple tags (`foo/bar/x.pdf` → `foo` *and* `bar`).

**Drop at the top level of `consume/` for no tag at all** — that's the right target
for miscellaneous documents, leaving classification to paperless's own workflow
rules in the web UI.

Add a directory to `scanTags` in `modules/services/scanner.nix` to add a new tagged
drop point. Paperless does not delete these directories after consuming from them.

### Transports

Both authenticate as the `scanner` system user (`users.users.scanner`).

**SFTP (primary)** — reuses the existing sshd. A `Match User scanner` block chroots
the account into `/var/lib/scan` and forces `internal-sftp`. `internal-sftp` is
required, not stylistic: the global `Subsystem sftp` points at a `/nix/store`
binary that doesn't exist inside the chroot. `-u 0022` forces uploads to mode 0644
so `paperless-consumer` can read them; deleting them afterwards is covered by the
0777 directory.

Password auth is off globally (`modules/core/ssh.nix`), so the scanner uses a key
pair. Generate it on the device (**Network > Security > Client Key Pair**), then
**Export Public Key**. The ADS-1700W exports directly in OpenSSH format
(`ssh-rsa AAAA... root@BR<mac>`) — no PEM/DER conversion needed — so the line goes
straight into `users.users.scanner.openssh.authorizedKeys.keys`. Public keys belong
in Nix here for the same reason `myconfig.constants.sshKeys` does.

Note the export produces a **2048-bit RSA** key. Browsers auto-save it without a
dialog; if the export seems to do nothing after showing "Request : Acknowledged",
check the downloads folder before assuming it failed.

**SMB (fallback)** — share `//bristlecone/scan` → `/var/lib/scan/consume`.
`force user = paperless` makes uploads land owned by paperless. `nmbd` is enabled
so the scanner's "Browse Network" button finds the host.

### Bootstrap after deploy

```bash
sudo smbpasswd -a scanner          # SMB password, kept out of Nix
ls -ld /var/lib/scan /var/lib/scan/consume
sudo sshd -T -C user=scanner | grep -iE 'chroot|forcecommand'
```

### Scanner profile settings

Browse to the scanner's IP, then **Scan > Scan to FTP/SFTP/Network**. Create one
profile per tag directory.

| Field | SFTP profile | SMB profile |
|---|---|---|
| Host Address | bristlecone's LAN IP | bristlecone's LAN IP |
| Port | 22 | 445 |
| Username | `scanner` | `scanner` |
| Auth Method | Public Key (Client Key Pair) | password from `smbpasswd` |
| Server Public Key | import `/etc/ssh/ssh_host_rsa_key.pub` — **not** the ed25519 one | — |
| Store Directory | `/consume/receipts` (absolute *inside the chroot*) | `scan/receipts` |

Per-profile scan settings worth using: 300 dpi, 2-sided (Long Edge), Auto Colour
Detect, **Skip Blank Page = On**, Auto Deskew = On, File Type = **PDF Multi-Page**
— plain PDF, not the device's searchable-PDF mode; paperless's OCRmyPDF pass is
better.

### Server host key: RSA only

The firmware rejects an Ed25519 server public key at upload time with *"The file
is either no longer available or does not contain a valid public key"* — the file
is fine, the algorithm just isn't supported. Import
`/etc/ssh/ssh_host_rsa_key.pub`.

The scanner also only offers the legacy SHA-1 `ssh-rsa` host key algorithm, which
OpenSSH has not offered by default since 8.8, so sshd needs:

```nix
services.openssh.settings.HostKeyAlgorithms = "+ssh-rsa";
```

This is host-wide — `HostKeyAlgorithms` is not a valid `Match` keyword. `+ssh-rsa`
appends to the defaults, so modern clients still negotiate ed25519/rsa-sha2 and
only fall back to SHA-1 if they explicitly ask. It affects host authentication
only; user pubkey auth is governed separately by `PubkeyAcceptedAlgorithms`.
Without it the scanner fails and sshd logs
`no matching host key type found. Their offer: ssh-rsa`.

### If the scanner can't connect

**MAC negotiation (hit in practice).** bristlecone's default MAC list is ETM-only;
the ADS-1700W offers only non-ETM. Empty intersection, so the connection dies
before authentication — and the scanner reports a misleading generic
"Authentication Error" for *any* connection failure, so always read the server log
rather than trusting its message:

```
Unable to negotiate with <scanner-ip>: no matching MAC found.
Their offer: hmac-sha2-256,hmac-sha2-512,hmac-sha1,hmac-sha1-96,hmac-md5,...
```

Fixed by appending the two SHA-2 non-ETM variants (and none of the SHA-1/MD5 ones
the firmware also offers) to `services.openssh.settings.Macs`. Like
`HostKeyAlgorithms`, `Macs` is not a valid `Match` keyword, so it's host-wide; the
ETM entries stay first so every other client still negotiates them. Note the full
list must be written out — any definition discards the option default.

For other algorithm classes, check `journalctl -u sshd | grep -i 'no matching'` and
add only what the log names. `Ciphers` and `KexAlgorithms` needed no change. If the
firmware ever demands SHA-1 MACs or MD5, use the SMB path instead of weakening SSH
for every client.

**RSA user-auth signature rejected (hit in practice).** The firmware signs user
authentication with SHA-1 `ssh-rsa`, which OpenSSH has refused since 8.8:

```
userauth_pubkey: signature algorithm ssh-rsa not in PubkeyAcceptedAlgorithms [preauth]
Connection closed by authenticating user scanner <scanner-ip> [preauth]
```

Unlike `Ciphers`/`MACs`/`HostKeyAlgorithms`, `PubkeyAcceptedAlgorithms` *is* valid
inside a `Match` block, so this one is scoped to the scanner alone via the existing
`Match User scanner` block:

```
  PubkeyAcceptedAlgorithms +ssh-rsa
```

Every other user on bristlecone keeps the default SHA-2-only policy — confirm with
`grep '^PubkeyAcceptedAlgorithms' /etc/ssh/sshd_config`, which should return
nothing.

**SMB:** older firmware may want SMB1/NT1, which Samba disallows by default. Update
the scanner's firmware first. `server min protocol = NT1` plus
`ntlm auth = ntlmv1-permitted` is a last resort and weakens SMB for every client.

---

## Backups (borgmatic)

`services.borgmatic` runs daily via upstream's `borgmatic.timer` and backs up
`/srv/share` plus the state of every service above (Home Assistant,
Zigbee2MQTT, Mosquitto, Paperless, Karakeep, Actual Budget, changedetection.io,
Jellyfin, 9router, Hermes Agent, Samba's passdb). `/srv/projects` is excluded — it lives in
remote git repos. Meilisearch and redis are skipped as rebuildable.

| | |
|---|---|
| Repository | `/var/lib/borg/bristlecone` (local, repokey-blake2) |
| Passphrase | `/var/lib/borgmatic/passphrase` (root, 0400, created out-of-band) |
| Retention | 7 daily, 4 weekly, 6 monthly |
| Checks | repository every 2 weeks, archives monthly |

SQLite databases (HA recorder, Paperless, Karakeep, Actual's `account.sqlite`, Jellyfin) are dumped
by borgmatic's `sqlite_databases` hook rather than copied raw, so restores are
consistent even though the services keep running. The hook creates an empty DB
at any configured path that doesn't exist, so update the list if a service
moves its database.

The repo shares a disk with everything it backs up — it protects against
deletion and corruption, not drive failure. Add an off-machine entry to
`repositories` for that.

### First-time setup

```bash
# Passphrase (keep a copy somewhere off this machine)
sudo install -d -m 0700 /var/lib/borgmatic
sudo install -m 0400 /dev/stdin /var/lib/borgmatic/passphrase   # paste, then Ctrl-D
sudo borgmatic repo-create --encryption repokey-blake2
# Export the key too — without it AND the passphrase the repo is unreadable
sudo borgmatic key export
sudo systemctl start borgmatic   # first run; then the timer takes over
```

### Common operations

```bash
sudo borgmatic list                                  # archives
sudo borgmatic info
sudo borgmatic extract --archive latest --path var/lib/hass --destination /tmp/restore
sudo borgmatic restore --archive latest --data-source home-assistant   # stop the service first
journalctl -u borgmatic
```

---

## Systemd Hardening

All services share a hardened baseline (`lib/hardened-service-config.nix`):

- `ProtectHome`, `ProtectKernelTunables/Modules/Logs`, `ProtectControlGroups`, `ProtectClock`
- `NoNewPrivileges`, `PrivateTmp`, `PrivateDevices`
- `RestrictRealtime`, `RestrictSUIDSGID`, `RestrictNamespaces`
- `LockPersonality`, `SystemCallArchitectures = native`
- Syscall filter: `@system-service` minus `@mount`, `@reboot`, `@swap`

Per-service overrides add `ReadWritePaths` or relax restrictions as needed.

Zigbee2MQTT and Actual Budget are the other exceptions. Upstream's unit is already stricter than
this baseline (`DevicePolicy=closed` with a `DeviceAllow` derived from
`serial.port`, `PrivateUsers`, `ProtectSystem=strict`, `ProtectProc=invisible`),
so it is deliberately *not* passed through `hardenedServiceConfig` — doing so
would loosen it. The same goes for Actual Budget (see its section above).

Hermes Agent takes the baseline without its syscall filter and namespace
restriction, because it runs arbitrary agent-installed tools (see its section above).
