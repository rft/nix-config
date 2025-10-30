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

## Niri Keybinds
- `Mod+Shift+Slash` shows the built-in hotkey overlay.
- `Mod+Return` launches `kitty`; `Mod+Space` opens rofi run; `Mod+P` raises the rofi window switcher; `Mod+Q` starts Floorp.
- `Mod+Shift+C` closes the focused window; `Mod+Ctrl+Space` toggles floating; `Mod+Shift+Q` quits the session without confirmation.
- `Mod+H/J/K/L` focus columns or windows; `Mod+Ctrl+H/J/K/L` move them; `Mod+Shift+H/J/K/L` focus adjacent monitors.
- `Mod+1…9` jump to workspaces; `Mod+Ctrl+1…9` move the current column; paging keys (`Mod+Page_Down/Page_Up`) and wheel binds navigate or move workspaces.
- All other defaults (overview on `Mod+O`, column resizing, screenshots, media/volume keys, etc.) remain unchanged from upstream Niri.
