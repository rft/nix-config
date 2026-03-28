# Setup and Usage

## Directory Structure

```
hosts/                  Per-host configurations (delib.host)
  bristlecone/          Desktop, KDE Plasma 6
  cottonwood/           Desktop, vertical screen
  redwood/              Desktop, full creative+engineering
  sequoia/              Desktop, VMware guest
  myrtle/               Desktop, archiving-focused, VMware guest
  mistletoe/            WSL, programming only
  lemon/                Darwin (macOS), Apple Silicon
  pineapple/            Darwin (macOS), Apple Silicon
modules/                Shared modules (delib.module)
  config/               Infrastructure (constants, user, overlays)
  core/                 Always-on system packages and xonsh
  desktop/              Desktop environment (noctalia, awesome, niri, rofi, login)
  applications/         NixOS-level GUI apps (creative, engineering, archiving)
  applications-home/    Home Manager GUI app configs (floorp, kando, kdenlive)
  programming/          Development tools (analysis, cloud)
  services/             Self-hosted services
  terminal/             Shell and terminal configs (kitty, starship, nushell, xonsh, zellij)
  editors/              Editor configurations (vscode, helix, doom-emacs)
  fonts/                Font packages and fontconfig
config/                 Static app configs (awesome, niri, kando)
lib/                    Shared Nix functions (python-core-packages, xonsh-extra-packages)
packages/               Custom packages (rofi-desktop, xxh)
docs/                   This documentation
```

## Hosts

The flake defines 9 hosts via `denix.lib.configurations`. Each host declares a
name, type, and system in `delib.host`. The type determines which base
extensions apply (host types: `desktop`, `server`, `wsl`, `installer`, `darwin`).

| Host | Type | Timezone | Notable Config |
|------|------|----------|----------------|
| **bristlecone** | desktop | America/Phoenix | KDE Plasma 6 with SDDM, GRUB+EFI |
| **cottonwood** | desktop | America/Los_Angeles | Vertical screen rotation (`fbcon=rotate:1`), GRUB+EFI |
| **redwood** | desktop | America/Los_Angeles | Full modules: creative + engineering explicitly enabled |
| **sequoia** | desktop | America/Phoenix | VMware guest, GRUB on `/dev/sda` |
| **myrtle** | desktop | America/Phoenix | VMware guest, archiving enabled, creative/engineering/programming disabled |
| **mistletoe** | wsl | -- | WSL host, programming + analysis + cloud, nix-ld enabled |
| **lemon** | darwin | -- | Apple Silicon Mac (aarch64-darwin), Touch ID sudo. Homebrew casks: discord, spotify, obs, mpv, calibre, anki, audacity, blender, krita, reaper, raycast, shortcat, linearmouse, orion, karabiner-elements, iina, plover, utm, espanso, obsidian, claude. App Store: Amphetamine, ProDrafts |
| **pineapple** | darwin | -- | Apple Silicon Mac (aarch64-darwin), Touch ID sudo, Nix GC disabled. Homebrew casks: discord, spotify, obs, mpv, calibre, anki, audacity, blender, krita, reaper, raycast, shortcat, linearmouse, orion, karabiner-elements, iina, plover, utm, espanso, obsidian, claude. App Store: Amphetamine, ProDrafts |
| **installer** | installer | -- | Live ISO, KDE Plasma 6 + Calamares, autologin as `nano`, flake embedded at `/etc/nixos-config` |

### Module enablement by host

| Module | bristlecone | cottonwood | redwood | sequoia | myrtle | mistletoe | lemon | pineapple | installer |
|--------|:-----------:|:----------:|:-------:|:-------:|:------:|:---------:|:-----:|:---------:|:---------:|
| desktop | yes | yes | yes | yes | yes | -- | -- | -- | -- |
| applications | yes | yes | yes | yes | yes | -- | yes | yes | -- |
| applications.creative | auto | auto | yes | yes | no | -- | auto | auto | -- |
| applications.engineering | auto | auto | yes | yes | no | -- | auto | auto | -- |
| applications.archiving | -- | -- | -- | -- | yes | -- | -- | -- | -- |
| programs.programming | yes | yes | yes | yes | no | yes | yes | yes | -- |
| programs.programming.analysis | auto | auto | auto | auto | -- | yes | auto | auto | -- |
| programs.programming.cloud | -- | -- | -- | -- | -- | yes | yes | yes | -- |
| services | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| terminal | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| editors | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| fonts | auto | auto | auto | auto | auto | -- | yes | yes | yes |

`yes` = explicitly enabled, `auto` = auto-enabled by parent, `no` = explicitly disabled, `--` = not enabled.

## How to Rebuild

Apply the NixOS configuration for a specific host:

```bash
sudo nixos-rebuild switch --flake .#HOSTNAME
```

For example:

```bash
sudo nixos-rebuild switch --flake .#bristlecone
```

## Darwin (macOS)

Darwin hosts use [nix-darwin](https://github.com/nix-darwin/nix-darwin) instead
of NixOS. The flake produces `darwinConfigurations` alongside
`nixosConfigurations` using the same denix module system.

### Prerequisites

1. Install Nix on macOS (the [Determinate Systems installer](https://zero-to-nix.com/start/install) is recommended).
2. Install [Homebrew](https://brew.sh) -- needed for cask management of GUI `.app` bundles.

### First-time setup

Bootstrap nix-darwin (only needed once):

```bash
nix run nix-darwin -- switch --flake .#lemon
```

### Rebuilding

After the initial bootstrap, use `darwin-rebuild`:

```bash
darwin-rebuild switch --flake .#lemon
```

### How modules work on Darwin

Denix modules support `darwin.always` / `darwin.ifEnabled` / `darwin.ifDisabled`
blocks alongside `nixos.*` blocks. The routing works as follows:

- **`darwin.*`** blocks are applied only when building `darwinConfigurations`.
- **`nixos.*`** blocks are skipped on Darwin.
- **`home.*`** blocks are applied on both NixOS and Darwin (routed through
  home-manager automatically).
- **`myconfig.*`** blocks are applied on all platforms.

For modules where the NixOS and Darwin config is identical (e.g. just
`environment.systemPackages`), both blocks need to be defined. Modules that
only use `home.*` blocks work on Darwin with zero changes.

### Shared Darwin defaults (`modules/config/darwin.nix`)

All Darwin hosts automatically receive shared defaults from
`modules/config/darwin.nix`. This module uses `darwin.always` with
`lib.mkDefault`, so every setting can be overridden per-host by setting the
value directly in the host's `darwin` block (direct values take priority over
`mkDefault`).

The shared module provides: Homebrew casks and App Store apps, system defaults
(dock, finder, trackpad, dark mode), Touch ID sudo, Nix GC settings, and
`system.stateVersion`.

### Finding Mac App Store IDs

To add a new App Store app to `masApps`, you need its numeric ID. Use the `mas`
CLI (installed via Homebrew brews in the shared Darwin config) to search:

```bash
mas search "App Name"
```

This returns matching apps with their IDs. Use the ID in the `masApps` attrset:

```nix
masApps = {
  "App Name" = 123456789;
};
```

To override a shared setting for a single host, set it in the host's `darwin`
block:

```nix
darwin = {
  networking.hostName = "pineapple";

  # Override shared defaults
  system.defaults.dock.autohide = true;
  homebrew.casks = [ "discord" "spotify" ];  # replaces the full list
};
```

To add extra Homebrew casks without replacing the shared list, use `lib.mkAfter`
or append via `++` in a `darwin.always` lambda in the host file.

### Adding a new Darwin host

1. Create `hosts/HOSTNAME/default.nix`:

```nix
{ delib, ... }:
delib.host {
  name = "HOSTNAME";
  type = "darwin";
  system = "aarch64-darwin";

  home.home.stateVersion = "24.05";

  darwin = {
    networking.hostName = "HOSTNAME";
  };

  myconfig = {
    constants.username = "yourusername";
    applications.enable = true;
    programs.programming.enable = true;
  };
}
```

Shared settings (Homebrew, system defaults, Touch ID, etc.) are applied
automatically by `modules/config/darwin.nix`. Only add host-specific overrides
to the `darwin` block.

2. No `hardware-configuration.nix` is needed for Darwin hosts.

3. Rebuild with `darwin-rebuild switch --flake .#HOSTNAME`.

### Key differences from NixOS hosts

| | NixOS | Darwin |
|--|-------|--------|
| Rebuild command | `sudo nixos-rebuild switch` | `darwin-rebuild switch` |
| Home directory | `/home/username` | `/Users/username` |
| Garbage collection | `nix.gc.dates` (systemd timer) | `nix.gc.interval` (launchd plist) |
| Shell config | `programs.xonsh.enable` | `environment.systemPackages` with `pkgs.xonsh.override` |
| GUI apps | Nix packages | Homebrew casks (better `.app` integration) |
| User config | `isNormalUser`, `extraGroups` | `home`, `description` only |
| Default shell | `users.defaultUserShell` | Not available |

## Installer ISO

Build a custom NixOS installer ISO with KDE Plasma 6, Calamares, and your
terminal tools (starship, kitty, helix, etc.) pre-configured.

### Building

```bash
nix build .#installer-iso
```

The ISO is written to `result/iso/`. To reduce build time during development the
default squashfs compression is zstd level 6. For a smaller release ISO, bump
the level to 19 in `hosts/installer/default.nix`.

### Writing to USB

```bash
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with your USB device (use `lsblk` to identify it).

### Installing a host

Boot the USB. KDE Plasma starts with auto-login as `nano`. The flake is
embedded at `/etc/nixos-config`.

1. Partition and mount disks (GParted is available, or use `parted`/`fdisk`).
2. Mount the target root at `/mnt` (and EFI partition at `/mnt/boot` if applicable).
3. Run the installer:

```bash
sudo nixos-install --flake /etc/nixos-config#HOSTNAME
```

For example, to install the bristlecone host:

```bash
sudo nixos-install --flake /etc/nixos-config#bristlecone
```

4. After installation completes, set the user password when prompted and reboot.

### Testing in a VM

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom result/iso/*.iso
```

## Standalone Home Manager

Standalone Home Manager lets you apply user-level configuration (shells,
editors, dotfiles, git, etc.) on any system with Nix installed -- even
non-NixOS Linux distros, macOS without nix-darwin, or WSL. It uses only the
`home.*` blocks from modules; `nixos.*` and `darwin.*` blocks are ignored.

The `homeManagerUser` is set to `"nano"` in the flake.

### Flake attribute naming

Denix keys standalone home configurations as `"<user>@<hostname>"`, so the
flake attribute is `homeConfigurations."nano@HOSTNAME"` (not `"nano"` or
`"HOSTNAME"` alone). Use this format in all `--flake` arguments.

### Prerequisites

1. Install Nix (the [Determinate Systems installer](https://zero-to-nix.com/start/install) is recommended).
2. Enable flakes if not already (the Determinate installer does this by default):

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Adding a host for a non-nano user

If the system user differs from `nano`, create a host entry that overrides the
username. For example, for a machine named `dandelion` with user `astro`:

```nix
{ delib, ... }:
delib.host {
  name = "dandelion";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "25.05";

  myconfig = {
    constants.username = "astro";
    constants.userfullname = "astro";
    programs.programming.enable = true;
  };
}
```

Note: the flake attribute key is always `nano@<hostname>` (from `homeManagerUser`
in the flake), regardless of `constants.username`. So the switch command is:

```bash
home-manager switch --flake '.#nano@dandelion'
```

### First-time bootstrap

If Home Manager is not yet installed, run it directly from the flake:

```bash
nix run home-manager -- switch --flake '.#nano@HOSTNAME'
```

This builds and activates the Home Manager configuration, and installs the
`home-manager` command into your profile.

### Rebuilding

After the initial bootstrap, use `home-manager` directly:

```bash
home-manager switch --flake '.#nano@HOSTNAME'
```

### Setting environment variables

Host-level environment variables (e.g. proxy settings) can be set via
`home.home.sessionVariables` in the host config:

```nix
{ delib, ... }:
delib.host {
  name = "dandelion";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "25.05";

  home.home.sessionVariables = {
    http_proxy = "http://proxy.example.com:8080";
    https_proxy = "http://proxy.example.com:8080";
    no_proxy = "localhost,127.0.0.1";
  };

  myconfig = {
    constants.username = "astro";
    constants.userfullname = "astro";
    programs.programming.enable = true;
  };
}
```

### What gets applied

Standalone Home Manager applies all `home.always` and `home.ifEnabled` blocks
from every module. This includes:

- Shell configuration (xonsh, nushell, starship, zellij)
- Terminal emulator config (kitty)
- Editor config (VSCodium extensions/settings, Helix)
- Git configuration
- User packages installed via `home.packages`
- Dotfiles managed via `home.file` and `xdg.configFile`

System-level configuration (`environment.systemPackages`, services, boot,
fonts, etc.) is **not** applied -- those require a full NixOS or Darwin rebuild.

### Troubleshooting

If you get a conflict with existing dotfiles, Home Manager will refuse to
overwrite them. Either back up and remove the conflicting files, or check
`result/` for the files Home Manager wants to write:

```bash
home-manager switch --flake '.#nano@HOSTNAME' 2>&1 | grep "Existing file"
```

## How to Add a New Host

1. Create `hosts/HOSTNAME/default.nix`:

```nix
{ delib, ... }:
delib.host {
  name = "HOSTNAME";
  type = "desktop";  # or "server" or "wsl"
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "25.11";
    imports = [ ./hardware-configuration.nix ];

    # Boot loader, networking, timezone, locale, etc.
    networking.hostName = "HOSTNAME";
    networking.networkmanager.enable = true;
    time.timeZone = "America/Los_Angeles";
  };

  myconfig = {
    # Enable the modules you want
    applications.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
```

2. Copy `hardware-configuration.nix` into the same directory. Generate it with:

```bash
nixos-generate-config --show-hardware-config > hosts/HOSTNAME/hardware-configuration.nix
```

3. Set `name`, `type`, `system`, and `stateVersion` appropriately.

4. Configure the `myconfig` block to enable/disable modules for this host.

5. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#HOSTNAME
```

## How to Add a New Module

1. Create a file in the appropriate category directory, e.g.
   `modules/CATEGORY/name.nix`:

```nix
{ delib, lib, pkgs, ... }:
delib.module {
  name = "CATEGORY.name";

  options = delib.singleEnableOption false;

  # Auto-enable when the parent module is enabled (optional)
  myconfig.always = { myconfig, ... }: {
    CATEGORY.name.enable = lib.mkDefault (myconfig.CATEGORY.enable or false);
  };

  # NixOS-level configuration (applied when enabled)
  # NOTE: these are plain attrsets, NOT lambdas. Add pkgs/lib to the
  # outer module function args instead.
  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      # packages here
    ];
  };

  # Home Manager configuration (applied when enabled)
  home.ifEnabled = {
    # HM config here
  };
}
```

2. The module is automatically discovered. Denix scans all paths listed in the
   flake's `paths` (which includes `./modules`), so no manual import is needed.

3. Rebuild to apply.

## How to Enable/Disable Modules per Host

In the host's `myconfig` block, set the module's enable option:

```nix
myconfig = {
  applications.enable = true;            # Enable the applications group
  applications.creative.enable = false;  # Override: disable creative sub-module
  programs.programming.enable = true;    # Enable programming tools
  programs.programming.cloud.enable = true;  # Explicitly enable cloud (no auto-enable)
};
```

Modules with `singleEnableOption true` (terminal, editors) are enabled by
default and do not need to be listed. To disable them for a specific host:

```nix
myconfig = {
  terminal.kitty.enable = false;  # Disable kitty on this host
};
```

## NixOS vs Home Manager Blocks

Each `delib.module` can contain both `nixos.*` and `home.*` config blocks:

- **`nixos.ifEnabled`** / **`nixos.always`** — NixOS-level config (system packages, services, boot, etc.). Only applied when building `nixosConfigurations` (i.e. `sudo nixos-rebuild switch --flake .#HOSTNAME`). Ignored in standalone Home Manager builds.
- **`home.ifEnabled`** / **`home.always`** — Home Manager config (user programs, dotfiles, etc.). Applied in **both** modes: as part of NixOS rebuilds (via the HM NixOS module) and in standalone HM builds (`home-manager switch --flake '.#nano@HOSTNAME'`).
- **`myconfig.always`** — Sets module option defaults. This is the only block that receives a lambda with `{ myconfig, ... }:` args. Use `lib.mkDefault` so host-level overrides take precedence.

**Important:** `nixos.ifEnabled` and `home.ifEnabled` are **plain attrsets**, not lambdas. If you need `pkgs`, `lib`, `inputs`, etc., add them to the outer module function args:

```nix
# Correct:
{ delib, pkgs, lib, ... }:
delib.module {
  name = "example";
  nixos.ifEnabled = {
    environment.systemPackages = [ pkgs.hello ];
  };
}

# Wrong — will error:
{ delib, ... }:
delib.module {
  name = "example";
  nixos.ifEnabled = { pkgs, ... }: {  # DO NOT use a lambda here
    environment.systemPackages = [ pkgs.hello ];
  };
}
```

### Building

```bash
# Full NixOS rebuild (applies both nixos.* and home.* blocks)
sudo nixos-rebuild switch --flake .#HOSTNAME

# Standalone Home Manager (applies only home.* blocks)
home-manager switch --flake '.#nano@HOSTNAME'
```

## Flake Architecture

The flake uses `denix.lib.configurations` with the `base` extension:

```nix
denix.lib.configurations {
  homeManagerUser = "nano";
  paths = [ ./hosts ./modules ];
  extensions = with denix.lib.extensions; [
    args
    (base.withConfig {
      args.enable = true;
      rices.enable = false;
      hosts.type.types = [ "desktop" "server" "wsl" "installer" "darwin" ];
    })
  ];
};
```

This generates `nixosConfigurations`, `darwinConfigurations`, and
`homeConfigurations` from the same host/module definitions. The `base` extension provides the host type
system and `myconfig` option merging.

### Key inputs

| Input | Purpose |
|-------|---------|
| nixpkgs | NixOS 25.11 stable channel |
| nixpkgs-unstable | Unstable channel (pinned packages via overlay) |
| home-manager | Home Manager release-25.11 |
| denix | Module/host framework |
| noctalia | Noctalia shell (desktop shell) |
| nixcats-nvim | Custom Neovim config |
| nix-vscode-extensions | VSCode marketplace extensions |
| nur | Nix User Repository (Floorp addons) |
| nix-doom-emacs-unstraightened | Doom Emacs for Nix |
| nixos-wsl | NixOS on WSL support |
| nix-darwin | macOS system configuration |
| quickshell | Quickshell (available as input) |
