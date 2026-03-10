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
- **Description:** Read-only user constants shared across all modules via `myconfig.constants`.
- **Options:**
  - `constants.username` -- `"nano"` (readOnly)
  - `constants.userfullname` -- `"nano"` (readOnly)
  - `constants.useremail` -- `"nano@nomolabs.net"` (readOnly)
  - `constants.gitname` -- `"rft"` (readOnly)
- **Default behavior:** Always active. Values are published to `args.shared.constants`.
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
- **Description:** Creates the NixOS user account with `networkmanager` and `wheel` groups. Enables flakes and nix-command experimental features.
- **Options:** None (always active).
- **Default behavior:** Always active for all NixOS hosts.
- **Dependencies:** `constants` (reads `myconfig.constants.username`).

### overlays

- **Path:** `modules/config/overlays.nix`
- **Name:** `overlays`
- **Description:** Configures nixpkgs overlays for both NixOS and Home Manager. Provides: unstable channel, pins `vscodium`/`helix`/`claude-code`/`codex`/`kando` to unstable, custom `xxh` package, NUR, and nix-vscode-extensions.
- **Options:** None (always active).
- **Default behavior:** Always active. Sets `config.allowUnfree = true`.
- **Dependencies:** Flake inputs (`nixpkgs-unstable`, `nur`, `nix-vscode-extensions`).

---

## Core

System-level packages and shell configuration. Always enabled, no toggle.

### core

- **Path:** `modules/core/default.nix`
- **Name:** `core`
- **Description:** Installs 60+ system packages (bat, ripgrep, fd, fzf, git, claude-code, codex, podman, yazi, yt-dlp, zellij, etc.). Enables Podman virtualisation with Docker Hub registry. Sets default user shell to xonsh. Configures weekly garbage collection (delete older than 30 days).
- **Options:** None (always active).
- **Default behavior:** Always active for all NixOS hosts.
- **Dependencies:** `nixcats-nvim` flake input (for Neovim).

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
- **Description:** Imports and enables Noctalia shell (both NixOS service and HM program). Sets Noctalia color scheme to Nord.
- **Default behavior:** Disabled by default. Enabled in desktop-type hosts via `myconfig.desktop.enable = true`.
- **Dependencies:** `noctalia` flake input.

### desktop.awesome

- **Path:** `modules/desktop/awesome.nix`
- **Name:** `desktop.awesome`
- **Enable option:** `myconfig.desktop.awesome.enable` (default: `false`)
- **Description:** Installs AwesomeWM with startx display manager. Adds autorandr and arandr packages. Enables libinput with natural scrolling.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`.

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
- **Description:** Configures Rofi launcher with Nord theme. Installs rofi-desktop (custom package) and libdbusmenu. Creates a systemd user service for the rofi-appmenu-service HUD.
- **Default behavior:** Auto-enables when `myconfig.desktop.enable` is true.
- **Dependencies:** `desktop`. Custom `rofi-desktop` package from `packages/rofi-desktop/`.

---

## Applications

GUI applications installed at the NixOS level. Gated by `applications.enable`.

### applications

- **Path:** `modules/applications/default.nix`
- **Name:** `applications`
- **Enable option:** `myconfig.applications.enable` (default: `false`)
- **Description:** Installs base GUI applications: anki, audacity, calibre, discord, flameshot, floorp-bin, dolphin, kitty, mpv, nsxiv, obs-studio, ollama, pciutils, plover, rofi, spotify.
- **Default behavior:** Disabled by default. Enabled per-host.
- **Dependencies:** None.

### applications.creative

- **Path:** `modules/applications/creative.nix`
- **Name:** `applications.creative`
- **Enable option:** `myconfig.applications.creative.enable` (default: `false`)
- **Description:** Creative tools: aseprite, blender, kdenlive, krita, reaper.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true. Can be explicitly disabled per-host (e.g., myrtle sets `false`).
- **Dependencies:** `applications`.

### applications.engineering

- **Path:** `modules/applications/engineering.nix`
- **Name:** `applications.engineering`
- **Enable option:** `myconfig.applications.engineering.enable` (default: `false`)
- **Description:** Engineering and reverse-engineering tools: alloy6, chirp, cutter, fiji, ghidra, imhex, kicad, pulseview, qemu, sdrangel, solvespace, virt-manager.
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true. Can be explicitly disabled per-host.
- **Dependencies:** `applications`.

### applications.archiving

- **Path:** `modules/applications/archiving.nix`
- **Name:** `applications.archiving`
- **Enable option:** `myconfig.applications.archiving.enable` (default: `false`)
- **Description:** Archiving tools: archivebox, gallery-dl, hydrus.
- **Default behavior:** Does NOT auto-enable with `applications`. Must be explicitly enabled per-host (e.g., myrtle).
- **Dependencies:** None (no auto-enable from parent).

---

## Applications (Home Manager)

GUI application configs managed through Home Manager. Located in `modules/applications-home/`.

### applications.floorp

- **Path:** `modules/applications-home/floorp.nix`
- **Name:** `applications.floorp`
- **Enable option:** `myconfig.applications.floorp.enable` (default: `false`)
- **Description:** Configures Floorp browser via Home Manager. Sets BROWSER env var. Installs ff2mpv-rust. Creates a default profile with 20+ NUR extensions (bitwarden, darkreader, ublock-origin, vimium-c, sponsorblock, sidebery, etc.).
- **Default behavior:** Auto-enables when `myconfig.applications.enable` is true.
- **Dependencies:** `applications`. NUR overlay (for `rycee.firefox-addons`).

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
- **Description:** Core development tools: direnv, nixd, nixfmt-rfc-style, nodejs 22, plantuml-c4, swi-prolog, Python 3.12 with core packages. Sets `nix.nixPath` to the flake's nixpkgs.
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
- **Description:** Self-hosted service packages: borgmatic, home-assistant, jellyfin, kasmweb, n8n, ollama, paperless-ng.
- **Default behavior:** Disabled by default. No host currently enables this.
- **Dependencies:** None.

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
- **Description:** Configures the Starship prompt with a custom Nord-themed two-line format. Shows username, hostname, shell indicator, directory, git info, language versions, command duration, time, and status symbols. Integrates with zsh and nushell.
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
- **Description:** Configures xonsh for Home Manager with atuin, starship, and zoxide init. Installs xxh (custom package) and Python with xonsh. Includes WSL path handling: strips `/mnt/c/` paths for performance and re-adds select Windows executables (VS Code).
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** `lib/xonsh-extra-packages.nix`. Custom `xxh` package from `packages/xxh/`.

### terminal.zellij

- **Path:** `modules/terminal/zellij.nix`
- **Name:** `terminal.zellij`
- **Enable option:** `myconfig.terminal.zellij.enable` (default: `true`)
- **Description:** Enables the Zellij terminal multiplexer with Nord color theme.
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** None.

---

## Editors

Editor configurations. Enabled by default (`singleEnableOption true`).

### editors

- **Path:** `modules/editors/default.nix`
- **Name:** `editors`
- **Enable option:** `myconfig.editors.enable` (default: `true`)
- **Description:** Base editor module. Imports the nix-doom-emacs-unstraightened HM module. Doom Emacs is declared but currently disabled (`enable = false`).
- **Default behavior:** Enabled by default for all hosts.
- **Dependencies:** `nix-doom-emacs-unstraightened` flake input.

### editors.vscode

- **Path:** `modules/editors/vscode.nix`
- **Name:** `editors.vscode`
- **Enable option:** `myconfig.editors.vscode.enable` (default: `true`)
- **Description:** Configures VSCodium with Wayland support (ozone flags). Installs 30+ extensions (Copilot, Vim, VSpaceCode, Nix IDE, Jupyter, Magit, Claude Code, etc.). Sets up VSpaceCode keybindings, Vim integration, language servers (nixd, Svelte, Python/Jedi with Ruff), and editor settings (FiraCode font, format-on-save, sticky scroll).
- **Default behavior:** Auto-enables when `myconfig.editors.enable` is true.
- **Dependencies:** `editors`. Overlays (`nix-vscode-extensions` for marketplace packages).

### editors.helix

- **Path:** `modules/editors/helix.nix`
- **Name:** `editors.helix`
- **Enable option:** `myconfig.editors.helix.enable` (default: `true`)
- **Description:** Configures the Helix editor with Monokai Pro Spectrum theme, cursor shapes (block/bar/underline for normal/insert/select), and Nix language support with nixfmt auto-formatting.
- **Default behavior:** Auto-enables when `myconfig.editors.enable` is true.
- **Dependencies:** `editors`.

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
