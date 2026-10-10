# Modules Reference

Every denix module in this configuration. Modules use `delib.module` with
`singleEnableOption` for toggling. The `myconfig` block controls per-host
defaults; hosts set overrides in their own `myconfig`.

---

## Config

Infrastructure modules that are always active. They have no enable option.

### constants

- **Path:** `modules/config/constants.nix`
- **Name:** `constants`
- **Description:** User constants shared across all modules via `myconfig.constants`. Defaults are set for the `nano` user but can be overridden per-host.
- **Options:**
  - `constants.username` -- default `"nano"`
  - `constants.userfullname` -- default `"nano"`
  - `constants.useremail` -- default `"nano@nomolabs.net"`
  - `constants.gitname` -- default `"rft"`
  - `constants.sshKeys` -- attrset of SSH public keys keyed by machine name (e.g. `{ lemon = "ssh-ed25519 ..."; }`). All keys are automatically authorized for the user on every NixOS host via the `user` module.
- **Default behavior:** Always active. Values are published to `args.shared.constants`.
- **Overriding:** Set any constant in a host's `myconfig` block, e.g. `constants.username = "astro"` for a machine with a different user. To add SSH keys, extend the `sshKeys` attrset.
- **Dependencies:** None.

### home

- **Path:** `modules/config/home.nix`
- **Name:** `home`
- **Description:** Base Home Manager configuration. Enables home-manager, sets home directory, configures git identity (using constants), and writes Claude Code settings.
- **Options:** None (always active).
- **Default behavior:** Always active for all hosts.
- **Dependencies:** `constants` (reads `myconfig.constants.username`, `myconfig.constants.gitname`, `myconfig.constants.useremail`).

### user

- **Path:** `modules/config/user.nix`
- **Name:** `user`
- **Description:** Creates the NixOS user account with `networkmanager` and `wheel` groups. Enables flakes and nix-command experimental features. Authorizes all SSH keys from `myconfig.constants.sshKeys` for the user.
- **Options:** None (always active).
- **Default behavior:** Always active for all NixOS hosts. All SSH public keys in `constants.sshKeys` are added to the user's `openssh.authorizedKeys.keys`.
- **Dependencies:** `constants` (reads `myconfig.constants.username`, `myconfig.constants.sshKeys`).

### overlays

- **Path:** `modules/config/overlays/`
- **Name:** `overlays`
- **Description:** Configures nixpkgs overlays for both NixOS and Home Manager. Provides: unstable channel, pins `vscodium`/`claude-code`/`kando` to unstable, custom `oh-my-pi` package, and nix-vscode-extensions.
- **Options:** None (always active).
- **Default behavior:** Always active. Sets `config.allowUnfree = true`.
- **Dependencies:** Flake inputs (`nixpkgs-unstable`, `nix-vscode-extensions`).

---

## Core

System-level packages and shell configuration. Always enabled, no toggle.

### core

- **Path:** `modules/core/default.nix`
- **Name:** `core`
- **Description:** Installs ~40 system packages shared across platforms (bat, ripgrep, fd, fzf, git, claude-code, codex, yazi, yt-dlp, zellij, etc.) plus a small Linux-only set (distrobox, podman, podman-tui, wl-clipboard, picat). Enables Podman virtualisation with Docker Hub registry. Sets default user shell to xonsh. Configures weekly garbage collection (delete older than 30 days).
- **Options:** None (always active).
- **Default behavior:** Always active for all NixOS hosts. On Darwin, only the shared package set is applied (`wl-clipboard` and other Linux-only packages are excluded).
- **Dependencies:** `nixcats-nvim` flake input (for Neovim).

### core.ssh

- **Path:** `modules/core/ssh.nix`
- **Name:** `core.ssh`
- **Enable option:** `myconfig.core.ssh.enable` (default: `true`)
- **Description:** Enables SSH key-only access across all hosts. On NixOS, enables the OpenSSH server with password authentication disabled, keyboard-interactive disabled, and root login prohibited. Opens firewall port 22. On all platforms (including Darwin), manages `~/.ssh/authorized_keys` via Home Manager using the public keys from `myconfig.constants.sshKeys`. On macOS, Remote Login must also be enabled manually in System Settings > General > Sharing.
- **Default behavior:** Enabled by default for all hosts. Can be disabled per-host.
- **Dependencies:** `constants` (reads `myconfig.constants.sshKeys`).

### core.xonsh

- **Path:** `modules/core/xonsh.nix`
- **Name:** `core.xonsh`
- **Description:** Enables the xonsh shell system-wide with extra packages from `lib/xonsh-extra-packages.nix`.
- **Options:** None (always active).
- **Default behavior:** Always active for all NixOS hosts.
- **Dependencies:** `lib/xonsh-extra-packages.nix`.

---

## Desktop

Desktop environment modules. The top-level `desktop` module gates all sub-modules.

### desktop

- **Path:** `modules/desktop/default.nix`
- **Name:** `desktop`
- **Enable option:** `myconfig.desktop.enable` (default: `false`)
- **Description:** Imports and enables Noctalia shell (both NixOS service and HM program). Sets Noctalia to a custom "Titanium" palette built from `lib/titanium-palette.nix` (shared with nvim, yazi, zellij and oh-my-pi).
- **Default behavior:** Disabled by default. Enabled in desktop-type hosts via `myconfig.desktop.enable = true`.
- **Dependencies:** `noctalia` flake input.

### desktop.paneru

- **Path:** `modules/desktop/paneru.nix`
- **Name:** `desktop.paneru`
- **Enable option:** `myconfig.desktop.paneru.enable` (default: `false`)
- **Description:** Installs and configures paneru, a sliding tiling window manager for macOS. Manages windows on an infinite horizontal strip — opening new windows never resizes existing ones. Configured via Home Manager with a launchd agent for automatic startup.
- **Default behavior:** Does NOT auto-enable with `desktop`. Must be explicitly enabled per-host (currently enabled on none — lemon moved to `desktop.nehir`). Darwin only.
- **Dependencies:** `paneru` flake input.
- **Keybindings:**

| Action | Binding |
|--------|---------|
| Focus west | `Cmd + H` |
| Focus east | `Cmd + L` |
| Focus north | `Cmd + K` |
| Focus south | `Cmd + J` |
| Swap west | `Shift + Cmd + H` |
| Swap east | `Shift + Cmd + L` |
| Swap north | `Shift + Cmd + K` |
| Swap south | `Shift + Cmd + J` |
| Resize (grow) | `Alt + R` |
| Shrink | `Alt + S` |
| Full width | `Alt + F` |
| Center | `Alt + C` |
| Toggle tiled/floating | `Ctrl + Alt + T` |
| Stack | `Alt + ]` |
| Unstack | `Alt + [` |
| Quit | `Ctrl + Alt + Q` |

### desktop.nehir

- **Path:** `modules/desktop/nehir.nix`
- **Name:** `desktop.nehir`
- **Enable option:** `myconfig.desktop.nehir.enable` (default: `false`)
- **Description:** Installs [Nehir](https://github.com/guria/nehir), a macOS scrolling tiling window manager built on Niri's column model, from the `guria/tap/nehir@rc` Homebrew cask (pinned to the release-candidate cask until 0.6.0 ships stable, to avoid windows being stranded off-screen after lid-open wake). Starts it at login via a launchd user agent.
- **Default behavior:** Does NOT auto-enable with `desktop`. Must be explicitly enabled per-host (lemon). Darwin only.
- **Dependencies:** Homebrew (`modules/config/darwin.nix`). lemon disables the macOS `⌥⌘Space` Finder-search shortcut so Nehir's command palette can use it.

### desktop.login

- **Path:** `modules/desktop/login.nix`
- **Name:** `desktop.login`
- **Enable option:** `myconfig.desktop.login.enable` (default: `false`)
- **Description:** Configures greetd with tuigreet as the login manager. Default session launches niri-session with Wayland environment variables.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`.

### desktop.niri

- **Path:** `modules/desktop/niri.nix`
- **Name:** `desktop.niri`
- **Enable option:** `myconfig.desktop.niri.enable` (default: `false`)
- **Description:** Sets up the Niri Wayland compositor via Home Manager. Symlinks config from `config/niri/`. Installs niri, kanshi, and wdisplays. Creates a systemd user service for the compositor.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`. Config files in `config/niri/`.

### desktop.rofi

- **Path:** `modules/desktop/rofi.nix`
- **Name:** `desktop.rofi`
- **Enable option:** `myconfig.desktop.rofi.enable` (default: `false`)
- **Description:** Configures Rofi launcher with a "titanium" theme generated from `lib/titanium-palette.nix`.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`.

### desktop.gtk

- **Path:** `modules/desktop/gtk.nix`
- **Name:** `desktop.gtk`
- **Enable option:** `myconfig.desktop.gtk.enable` (default: `false`)
- **Description:** Dark GTK theming: adw-gtk3-dark theme, breeze-dark icons, and GTK3/GTK4 colour overrides generated from `lib/titanium-palette.nix` (libadwaita ignores themes, so the overrides carry GTK4). Sets the `breeze_cursors` pointer theme (size 24) so niri and Electron apps get resize/grab cursor shapes. Enables dconf on NixOS.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`.

### desktop.qt

- **Path:** `modules/desktop/qt.nix`
- **Name:** `desktop.qt`
- **Enable option:** `myconfig.desktop.qt.enable` (default: `false`)
- **Description:** Themes Qt/KDE apps (e.g. Dolphin) outside Plasma using the KDE platform theme with the Breeze style, breeze-dark icons, and a "Titanium" `kdeglobals` colour scheme from `lib/titanium-palette.nix`.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`.

### desktop.wallpaper

- **Path:** `modules/desktop/wallpaper.nix`
- **Name:** `desktop.wallpaper`
- **Enable option:** `myconfig.desktop.wallpaper.enable` (default: `false`)
- **Description:** Animated "Melancholic Forest" live wallpaper played by mpvpaper as a systemd user service (pauses while windows fully cover it). Disables Noctalia's own wallpaper and uses the video's first frame as the lock-screen image.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop` (Noctalia settings).

---

## Applications

GUI applications installed at the NixOS level. Gated by `applications.enable`.

### applications

- **Path:** `modules/applications/default.nix`
- **Name:** `applications`
- **Enable option:** `myconfig.applications.enable` (default: `false`)
- **Description:** Installs base GUI applications: anki, audacity, calibre, discord, flameshot, dolphin, imv (default image viewer), kitty, mpv, obs-studio, ollama, pciutils, plover, rofi, spotify.
- **Default behavior:** Disabled by default. Enabled per-host.
- **Dependencies:** None.

### applications.creative

- **Path:** `modules/applications/creative.nix`
- **Name:** `applications.creative`
- **Enable option:** `myconfig.applications.creative.enable` (default: `false`)
- **Description:** Creative tools: aseprite, blender (plus the Blender Lab MCP server and add-on), kdenlive, krita, reaper.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true. Can be explicitly disabled per-host (e.g., myrtle sets `false`).
- **Dependencies:** `applications`.

### applications.engineering

- **Path:** `modules/applications/engineering.nix`
- **Name:** `applications.engineering`
- **Enable option:** `myconfig.applications.engineering.enable` (default: `false`)
- **Description:** Engineering and reverse-engineering tools: alloy6, chirp, fiji, ghidra, imhex, kicad, pulseview, qemu, sdrangel, solvespace, virt-manager.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true. Can be explicitly disabled per-host.
- **Dependencies:** `applications`.

### applications.archiving

- **Path:** `modules/applications/archiving.nix`
- **Name:** `applications.archiving`
- **Enable option:** `myconfig.applications.archiving.enable` (default: `false`)
- **Description:** Archiving tools: archivebox, gallery-dl, hydrus.
- **Default behavior:** Does NOT auto-enable with `applications`. Must be explicitly enabled per-host (e.g., myrtle).
- **Dependencies:** None (no auto-enable from parent).

### applications.gaming

- **Path:** `modules/applications/gaming.nix`
- **Name:** `applications.gaming`
- **Enable option:** `myconfig.applications.gaming.enable` (default: `false`)
- **Description:** Gaming stack. NixOS: Steam (with extest, protontricks, Proton-GE), gamescope, gamemode, heroic, lutris, mangohud, prismlauncher, protonup-qt. Darwin: Steam via Homebrew cask.
- **Default behavior:** Does NOT auto-enable with `applications`. Must be explicitly enabled per-host (currently enabled on none).
- **Dependencies:** None (no auto-enable from parent).

---

## Applications (Home Manager)

GUI application configs managed through Home Manager. Located in `modules/applications-home/`.

### applications.helium

- **Path:** `modules/applications-home/helium.nix`
- **Name:** `applications.helium`
- **Enable option:** `myconfig.applications.helium.enable` (default: `false`, auto-enabled by `applications`)
- **Description:** Installs Helium (Linux only, via the `helium` flake input) with managed Chromium policies: Kagi default search, `r`/`y`/`a` site searches (subreddit, YouTube, Amazon), blank new tab, and force-installed Chrome Web Store extensions. Loads a titanium-palette theme with `--force-dark-mode`, seeds pinned toolbar order plus the split tab and DevTools toolbar buttons on activation, and sets Helium as BROWSER and (via xdg-mime) default for http/https/html.

### applications.kando

- **Path:** `modules/applications-home/kando.nix`
- **Name:** `applications.kando`
- **Enable option:** `myconfig.applications.kando.enable` (default: `false`)
- **Description:** Installs Kando radial menu and creates a systemd user service to run it in the background. Writes a declarative `menus.json` config with application launchers, Rofi integration, and session controls.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true.
- **Dependencies:** `applications`.

### applications.kdenlive

- **Path:** `modules/applications-home/kdenlive.nix`
- **Name:** `applications.kdenlive`
- **Enable option:** `myconfig.applications.kdenlive.enable` (default: `false`)
- **Description:** Fetches and installs custom KDEnlive keyboard shortcuts from an external source.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true.
- **Dependencies:** `applications`.

---

## Programming

Development tools. Gated by `programs.programming.enable`.

### programs.programming

- **Path:** `modules/programming/default.nix`
- **Name:** `programs.programming`
- **Enable option:** `myconfig.programs.programming.enable` (default: `false`)
- **Description:** Core development tools: direnv, nixd, nixfmt, nodejs 22, cucumber, plantuml-c4, texlab, TeX Live (scheme-medium), Python 3.13 with core packages. Sets `nix.nixPath` to the flake's nixpkgs.
- **Default behavior:** Disabled by default. Enabled per-host.
- **Dependencies:** `lib/python-core-packages.nix`.

### programs.programming.analysis

- **Path:** `modules/programming/analysis.nix`
- **Name:** `programs.programming.analysis`
- **Enable option:** `myconfig.programs.programming.analysis.enable` (default: `false`)
- **Description:** Security analysis and formal verification tools: aflplusplus, binwalk, file, tlaplusToolbox, tlaps.
- **Default behavior:** Auto-enables when `myconfig.programs.programming.enable` is true.
- **Dependencies:** `programs.programming`.

### programs.programming.cloud

- **Path:** `modules/programming/cloud.nix`
- **Name:** `programs.programming.cloud`
- **Enable option:** `myconfig.programs.programming.cloud.enable` (default: `false`)
- **Description:** Cloud infrastructure tools: google-cloud-sdk, terraform.
- **Default behavior:** Does NOT auto-enable with `programs.programming`. Must be explicitly enabled per-host (e.g., mistletoe).
- **Dependencies:** None (no auto-enable from parent).

---

## Services

Self-hosted services. Gated by `services.enable`.

### services

- **Path:** `modules/services/default.nix`
- **Name:** `services`
- **Enable option:** `myconfig.services.enable` (default: `false`)
- **Description:** Self-hosted services for headless servers. Enables: Jellyfin (media server), Mosquitto (MQTT broker), Home Assistant (home automation), n8n (workflow automation), Paperless (document management), Kasm Workspaces (browser/desktop streaming), changedetection.io (website monitoring), Karakeep (bookmarks), Zigbee2MQTT (Zigbee → MQTT bridge), and 9router (shared AI gateway). Also sets up scanner ingest into Paperless (SFTP jail + Samba share) and runs daily borgmatic backups of `/srv/share` and service state. See `docs/SERVICES.md` for the full reference.
- **Default behavior:** Disabled by default. Enabled on bristlecone (server host).
- **Services and ports:**
  - **Jellyfin** — media server (firewall auto-opened, port 8096)
  - **Mosquitto** — MQTT broker (port 1883, firewall opened manually; per-user ACLs for `hass` and the `livegrid` panel)
  - **Home Assistant** — home automation (firewall auto-opened, default port 8123)
  - **n8n** — workflow automation (firewall auto-opened, default port 5678)
  - **Paperless** — document management (port 28981, firewall opened manually; consume dir at `/var/lib/scan/consume`, subdirs become tags)
  - **Samba** — SMB share `//bristlecone/scan` for the document scanner (ports 139/445, firewall auto-opened; SFTP on port 22 is the primary transport)
  - **Kasm Workspaces** — browser/desktop streaming (port 8443 HTTPS, firewall opened manually)
  - **changedetection.io** — website change monitoring (port 5000, firewall opened manually)
  - **Karakeep** — bookmarks / read-it-later (port 3000, firewall opened manually; pulls in meilisearch on localhost:7700 and a headless chromium on localhost:9222)
  - **Zigbee2MQTT** — Zigbee coordinator bridged into Mosquitto/Home Assistant (frontend on port 8080, firewall opened manually)
  - **9router** — AI gateway shared by the other hosts (port 20128, reachable only on the Netbird interface `wt0`)
- **Dependencies:** None.

---

## Security

Opt-in system hardening.

### security

- **Path:** `modules/security/default.nix`
- **Name:** `security`
- **Enable option:** `myconfig.security.enable` (default: `false`)
- **Description:** Enables [nix-mineral](https://github.com/cynicsketch/nix-mineral) with its default preset plus opt-in extras from the maximum preset (`lock-root`, `minimize-swapping`, `secure-chrony`, `bluetooth-kmodules`, `tcp-window-scaling`). DNSSEC is deliberately left off. Because nix-mineral mounts `/home` noexec, it punches a narrow exec bind mount for `~/.omp/natives` so oh-my-pi can load its native modules.
- **Default behavior:** Disabled by default. Enabled on bristlecone. NixOS only.
- **Dependencies:** `nix-mineral` flake input (imported on every NixOS host, active only when enabled).

---

## Terminal

Shell and terminal emulator configuration. Enabled by default (`singleEnableOption true`).

### terminal

- **Path:** `modules/terminal/default.nix`
- **Name:** `terminal`
- **Enable option:** `myconfig.terminal.enable` (default: `true`)
- **Description:** Configures zsh (with autosuggestion, syntax highlighting, completion) and bash. Enables atuin (shell history sync for bash/zsh/nushell) and zoxide (smart cd for zsh/bash). Adds kitty hyperlink integration for ripgrep.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### terminal.kitty

- **Path:** `modules/terminal/kitty.nix`
- **Name:** `terminal.kitty`
- **Enable option:** `myconfig.terminal.kitty.enable` (default: `true`)
- **Description:** Configures the Kitty terminal emulator with cursor trail, FiraCode Nerd Font, and disabled close confirmations.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### terminal.starship

- **Path:** `modules/terminal/starship.nix`
- **Name:** `terminal.starship`
- **Enable option:** `myconfig.terminal.starship.enable` (default: `true`)
- **Description:** Configures the Starship prompt with a custom two-line format themed with "titanium" (palette from `lib/titanium-palette.nix`, shared with nvim, oh-my-pi, yazi and zellij). Shows username, hostname, shell indicator, directory, git info, language versions, command duration, time, and status symbols. Integrates with zsh and nushell.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### terminal.nushell

- **Path:** `modules/terminal/nushell.nix`
- **Name:** `terminal.nushell`
- **Enable option:** `myconfig.terminal.nushell.enable` (default: `true`)
- **Description:** Configures Nushell with carapace completions (fuzzy matching), zoxide, yazi, starship, broot, and eza integrations. Adds kitty hyperlink support for ripgrep.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### terminal.xonsh

- **Path:** `modules/terminal/xonsh.nix`
- **Name:** `terminal.xonsh`
- **Enable option:** `myconfig.terminal.xonsh.enable` (default: `true`)
- **Description:** Configures xonsh for Home Manager with atuin, starship, and zoxide init. Installs Python with xonsh. Includes WSL path handling: strips `/mnt/c/` paths for performance and re-adds select Windows executables (VS Code).
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** `lib/xonsh-extra-packages.nix`.

### terminal.zellij

- **Path:** `modules/terminal/zellij.nix`
- **Name:** `terminal.zellij`
- **Enable option:** `myconfig.terminal.zellij.enable` (default: `true`)
- **Description:** Enables the Zellij terminal multiplexer with the "titanium" theme (palette from `lib/titanium-palette.nix`, shared with yazi, nvim and oh-my-pi).
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### terminal.yazi

- **Path:** `modules/terminal/yazi.nix`
- **Name:** `terminal.yazi`
- **Enable option:** `myconfig.terminal.yazi.enable` (default: `true`)
- **Description:** Configures the Yazi file manager (via home-manager, `package = null`) with the "titanium" theme from `lib/titanium-palette.nix` (shared with zellij, nvim and oh-my-pi). Adds the `y` shell wrapper that changes directory on exit.
- **Default behavior:** Enabled by default for all hosts. The yazi binary itself comes from `core`.
- **Dependencies:** `core` (installs `yazi`).

---

## Editors

Editor configurations. Enabled by default (`singleEnableOption true`).

### editors

- **Path:** `modules/editors/default.nix`
- **Name:** `editors`
- **Enable option:** `myconfig.editors.enable` (default: `true`)
- **Description:** Parent toggle for the editor sub-modules (`editors.vscode`, `editors.opencode`). Has no configuration of its own. Neovim (nixcat-nvim) is installed by `core`, not here.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

### editors.vscode

- **Path:** `modules/editors/vscode.nix`
- **Name:** `editors.vscode`
- **Enable option:** `myconfig.editors.vscode.enable` (default: `true`)
- **Description:** Configures VSCodium with Wayland support (ozone flags). Installs 30+ extensions (Copilot, Vim, VSpaceCode, Nix IDE, Jupyter, Magit, Claude Code, etc.). Sets up VSpaceCode keybindings, Vim integration, language servers (nixd, Svelte, Python/Jedi with Ruff), and editor settings (FiraCode font, format-on-save, sticky scroll).
- **Default behavior:** Auto-enables when `myconfig.editors.enable` is true.
- **Dependencies:** `editors`. Overlays (`nix-vscode-extensions` for marketplace packages).

#### Shared VSpaceCode / Neovim keys

The [keybinding reference](KEYBINDINGS.md) documents the shared editor layout,
editor-specific actions and differences, and the complete active Niri keymap.
VSpaceCode uses `vspacecode.bindingOverrides`; Neovim's matching bindings live
in `rft/nixcat-nvim`.

For unpublished changes in a local Neovim checkout, follow the
[local input override instructions](KEYBINDINGS.md#local-neovim-checkout).
Without an override or updated lock entry, this flake still selects the
published Neovim revision rather than the local checkout.

### editors.opencode

- **Path:** `modules/editors/opencode.nix`
- **Name:** `editors.opencode`
- **Enable option:** `myconfig.editors.opencode.enable` (default: `true`)
- **Description:** Writes the global OpenCode config (`~/.config/opencode/opencode.json`) with an Ollama provider pointing to `pineapple.netbird.cloud:11434` using the `gemma4:26b` model. Disables built-in free models so only the Ollama provider is available.
- **Default behavior:** Auto-enables when `myconfig.editors.enable` is true. To disable on a specific host, set `myconfig.editors.opencode.enable = false`.
- **Dependencies:** `editors`. Requires Netbird connectivity to reach Ollama on pineapple.

---

## Fonts

Font packages and fontconfig. Auto-enables with desktop.

### fonts

- **Path:** `modules/fonts/default.nix`
- **Name:** `fonts`
- **Enable option:** `myconfig.fonts.enable` (default: `false`)
- **Description:** Installs Nerd Fonts (FiraCode, JetBrains Mono), Fira Code symbols, and Inter. Configures fontconfig defaults: Inter for serif/sans-serif, FiraCode for monospace.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop` (via auto-enable).
