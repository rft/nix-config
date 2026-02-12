# Yuki 
My NixOS flake

# Systems
- cottonwood
- sequoia 
- redwood
- Mistletoe (WSL)
- Cuscuta (WSL)

# Commands
`sudo nixos-rebuild switch --flake .#mistletoe`
`sudo nixos-rebuild switch --flake .#cuscuta`

## Packages (grouped by folder/category)
### Core (modules/nixos/core)
- atuin
- bandwhich
- bat
- binsider
- bottom
- bpftrace
- claude-code
- codex
- copilot-cli
- cpuid
- csvlens
- difftastic
- distrobox
- dua
- ethtool
- fd
- ffmpeg_7-full
- fzf
- gemini-cli
- gh
- git
- hexyl
- nixcats-nvim (inputs.nixcats-nvim)
- iproute2
- jq
- lazygit
- msr-tools
- nicstat
- numactl
- oxker
- pandoc
- pass
- picat
- podman
- podman-tui
- procps
- procs
- rclone
- rink
- ripgrep
- rr
- rsync
- syncthing
- sysstat
- tcpdump
- tealdeer
- tio
- tiptop
- tokei
- trippy
- util-linux
- visidata
- watchexec
- wget
- yazi
- yq
- yt-dlp
- zellij
- zoxide

### Applications (modules/nixos/applications)
#### Base (modules/nixos/applications/default.nix)
- anki
- audacity
- calibre
- discord
- flameshot
- floorp-bin
- kdePackages.dolphin
- kitty
- mpv
- nsxiv
- obs-studio
- ollama
- pciutils
- plover.dev
- rofi
- spotify

#### Creative (modules/nixos/applications/creative)
- aseprite
- blender
- kdePackages.kdenlive
- krita
- reaper

#### Engineering (modules/nixos/applications/engineering)
- alloy6
- chirp
- cutter
- fiji
- ghidra
- imhex
- kicad
- pulseview
- qemu
- sdrangel
- solvespace
- virt-manager

#### Archiving (modules/nixos/archiving)
- archivebox
- galllery-dl
- hydrus

### Programming (modules/nixos/programming)
#### Base (modules/nixos/programming/default.nix)
- direnv
- nixd
- nixfmt-rfc-style
- nodejs_22
- plantuml-c4
- swi-prolog
- python312.withPackages(python-core-packages)

#### Analysis (modules/nixos/programming/analysis)
- aflplusplus
- binwalk
- file
- tlaplusToolbox
- tlaps

#### Cloud (modules/nixos/programming/cloud)
- google-cloud-sdk
- terraform

#### Python core packages (lib/python-core-packages.nix)
- beautifulsoup4
- distributed
- ipdb
- ipython
- jax
- matplotlib
- numpy
- ortools
- pandas
- polars
- qrcode
- requests
- scapy
- scipy
- seaborn
- selenium
- sympy
- tqdm
- wat
- z3-solver

### Services (modules/nixos/services)
- borgmatic
- home-assistant
- jellyfin
- kasmweb
- n8n
- ollama
- paperless-ng

### Desktop (modules/nixos/desktop/awesome)
- autorandr
- arandr

### Home (homes/x86_64-linux/nano)
#### Fonts (homes/x86_64-linux/nano/fonts)
- fira-code-symbols
- inter
- nerd-fonts.fira-code
- nerd-fonts.jetbrains-mono

#### Applications (homes/x86_64-linux/nano/applications/floorp)
- ff2mpv-rust
- floorp-bin
- Floorp extensions (NUR): auto-tab-discard, bitwarden, clearurls, darkreader, dearrow, decentraleyes, gesturefy, multi-account-containers, old-reddit-redirect, privacy-badger, reddit-enhancement-suite, return-youtube-dislikes, sidebery, sponsorblock, stylus, temporary-containers, terms-of-service-didnt-read, videospeed, vimium-c, violentmonkey, ublock-origin

#### Desktop (homes/x86_64-linux/nano/desktop)
- niri
- kanshi
- wdisplays
- rofi
- rofi-desktop (inputs.self.packages)
- libdbusmenu

#### Terminal (homes/x86_64-linux/nano/terminal)
- starship
- xxh
- python3.withPackages(xonsh + xonsh-extra-packages)

#### Editors (homes/x86_64-linux/nano/editors/vscode)
- vscodium-wayland
- VS Code extensions: aaron-bond.better-comments, brettm12345.nixfmt-vscode, github.copilot, github.copilot-chat, jebbs.plantuml, jnoortheen.nix-ide, mechatroner.rainbow-csv, mkhl.direnv, ms-toolsai.jupyter, ms-toolsai.jupyter-keymap, ms-toolsai.jupyter-renderers, ms-toolsai.vscode-jupyter-cell-tags, ms-toolsai.vscode-jupyter-slideshow, ms-vscode-remote.remote-ssh, ms-vscode.live-server, oderwat.indent-rainbow, usernamehw.errorlens, vscodevim.vim, vspacecode.vspacecode, vspacecode.whichkey, yzhang.markdown-all-in-one, svelte.svelte-vscode, streetsidesoftware.code-spell-checker, github.vscode-github-actions, charliermarsh.ruff, buenon.scratchpads, bodil.file-browser, jacobdufault.fuzzy-search, kahole.magit, maattdd.gitless, roipoussiere.cadquery, tonybaloney.vscode-pets, bernhard-42.ocp-cad-viewer, anthropic.claude-code, marimo-team.vscode-marimo, openai.chatgpt, astral-sh.ty


### Packages (packages/)
- rofi-desktop
- xxh

### Xonsh extras (lib/xonsh-extra-packages)
#### Shared
- python-core-packages
- xxh
#### Xontribs
- xontrib-vox
- xonsh-direnv
- xontrib-whole-word-jumping
- xontrib-bashisms

## Niri Keybinds
- `Mod+Shift+Slash` shows the built-in hotkey overlay.
- `Mod+Return` launches `kitty`; `Mod+Space` opens rofi run; `Mod+P` raises the rofi window switcher; `Mod+Q` starts Floorp.
- `Mod+Shift+C` closes the focused window; `Mod+Ctrl+Space` toggles floating; `Mod+Shift+Q` quits the session without confirmation.
- `Mod+H/J/K/L` focus columns or windows; `Mod+Ctrl+H/J/K/L` move them; `Mod+Shift+H/J/K/L` focus adjacent monitors.
- `Mod+1…9` jump to workspaces; `Mod+Ctrl+1…9` move the current column; paging keys (`Mod+Page_Down/Page_Up`) and wheel binds navigate or move workspaces.
- All other defaults (overview on `Mod+O`, column resizing, screenshots, media/volume keys, etc.) remain unchanged from upstream Niri.
