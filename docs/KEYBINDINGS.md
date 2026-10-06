# Keybindings

Reference for the shared VSpaceCode/Neovim layout, editor-specific shortcuts, and **every active binding in this repository's Niri configuration**. This is not an exhaustive list of upstream Vim commands or extension defaults.

## Contents

- [Notation and scope](#notation-and-scope)
- [Shared editor bindings](#shared-editor-bindings)
- [Editor-specific bindings](#editor-specific-bindings)
- [Niri window manager](#niri-window-manager)
- [Conflicts and safety](#conflicts-and-safety)
- [Sources and deployment](#sources-and-deployment)

## Notation and scope

- `SPC f f` means press Space, then `f`, then `f`; do not hold Space.
- `Ctrl+J` and `Mod+H` mean hold the modifier while pressing the key.
- Editor sequences are case-sensitive: `SPC c r` is references; `SPC c R` is rename.
- **N** = normal mode; **V** = visual selection. Editor bindings below are normal-mode bindings unless another mode is listed. They are not insert-mode shortcuts.
- Niri's **Mod** is **Super** (Windows/Command key) in a normal desktop session, but **Alt** when Niri runs nested as a winit window. Explicit `Super` bindings always mean Super.
- Niri letters use XKB key names: `Mod+H` does **not** imply Shift. `Mod+Shift+H` does.
- Editor windows are splits/editor groups. Niri windows are application windows; Niri columns can contain several vertically stacked windows. Editor projects and Niri workspaces are different concepts.

**Deployment note:** the shared layout describes the edited Neovim checkout and this repository's VSpaceCode configuration. The committed Neovim flake pin currently predates those changes. Use the [local input override](#local-neovim-checkout) until the Neovim changes are published and the pin is updated.

## Shared editor bindings

VSpaceCode runs in VSCodium with VSCodeVim. Neovim uses the `nixcat-nvim` configuration. The bindings match action intent, not necessarily picker appearance, search scope, or plugin UI.

### Discovery, files, and buffers

| Keys | Action | Notes |
|---|---|---|
| `SPC` | Begin the leader menu | VSpaceCode menu / Neovim which-key hints; N and V |
| `SPC SPC` | Command palette | Editor commands, not the desktop launcher |
| `SPC f f` | Find a file | VS Code Quick Open / Neovim smart file picker |
| `SPC f o` | Browse the filesystem | File Browser / Oil |
| `SPC f r` | Open recent | VSpaceCode includes files **and workspaces**; Neovim lists recent files |
| `SPC f s` | Save file | |
| `SPC f t` | Toggle file tree | Explorer / Neo-tree |
| `SPC b b` | Pick an open buffer | VSpaceCode lists editor tabs; Neovim filters to the workspace |
| `SPC b n` | Next buffer | |
| `SPC b p` | Previous buffer | |
| `SPC b s` | New scratch/untitled buffer | |
| `SPC b N` | New buffer | Neovim also enters insert mode |
| `SPC b d` | Close/delete buffer | Unsaved-buffer handling is editor-specific |
| `SPC b t` | Toggle buffer pin | A VSpaceCode pin is a sticky tab |
| `SPC b P` | Close unpinned buffers | Keeps pinned buffers/tabs |
| `SPC b h` / `SPC b j` / `SPC b k` / `SPC b l` | Move buffer left/down/up/right | Neovim displays it in the adjacent window; VSpaceCode moves the tab to that group |

### Search, code, and diagnostics

| Keys | Action | Mode / scope |
|---|---|---|
| `SPC s s` | Search current file | Fuzzy line search |
| `SPC s p` / `SPC /` | Search project | Each editor's search settings apply; Neovim's enhanced grep includes hidden and ignored files |
| `SPC s R` | Project search and replace | VS Code Replace in Files / grug-far; Neovim V mode seeds the search from the selection |
| `SPC c d` | Go to definition | Language support required |
| `SPC c r` | Find references | N, V; Neovim installs this when an LSP attaches |
| `SPC c R` | Rename symbol | Language support required |
| `SPC c k` | Hover documentation | Language support required |
| `SPC c t` | Go to type definition | Language support required |
| `SPC c f` | Format buffer / selection | N: whole buffer; V: selection. Neovim linewise/block selections format their covered lines |
| `SPC e f` | Quick fix / code action | Requires a provider and applicable action |
| `SPC e l` | Diagnostics list | Native editor diagnostics UI |
| `SPC ;` | Toggle comment | N: current line; V: selected lines |

### Git, splits, and terminal

| Keys | Action | Notes |
|---|---|---|
| `SPC g g` | Git status | Magit / Neogit |
| `SPC g s` | Stage hunk / selection | N: cursor hunk; V: selected changes |
| `SPC g S` | Stage file | |
| `SPC w /` | Split vertically | Right-hand split in VSpaceCode |
| `SPC w -` | Split horizontally | Lower split in VSpaceCode |
| `SPC w h` / `SPC w j` / `SPC w k` / `SPC w l` | Focus left/down/up/right split | |
| `SPC w H` / `SPC w J` / `SPC w K` / `SPC w L` | Move split left/down/up/right | |
| `SPC w w` | Focus next split | |
| `SPC w c` | Close split | VS Code protects pinned tabs; Neovim prompts where needed |
| `SPC w o` | Keep only current split | VSpaceCode merges groups, retaining their tabs; Neovim keeps the current window |
| `SPC w m` | Toggle maximized split | Neovim restores equalized sizes, not an arbitrary previous layout |
| `SPC o t` | Toggle terminal | Integrated panel / Neovim floating terminal |

## Editor-specific bindings

### VSpaceCode menus and retained actions

| Keys | Action |
|---|---|
| `SPC m` | Language-specific menu; available actions depend on the current language |
| `SPC f O` | Open current file with another editor |
| `SPC b y` | Paste clipboard into a new untitled buffer |
| `SPC s a` | Find references in the sidebar |
| `SPC s C` | Toggle search case sensitivity |
| `SPC w f` | Switch application window/frame |
| `Ctrl+Shift+J` | Quick Open |
| `Space` in an empty editor area or non-input sidebar | Open the VSpaceCode menu |

Bare `,` no longer opens the language menu: it retains Vim's reverse-repeat of a character search (`f`, `t`, `F`, `T`). `SPC m` remains the language-menu entry point. In Neovim, `SPC m` is instead the notes group.

### VSpaceCode popup navigation

| Context | Keys | Action |
|---|---|---|
| Quick Open | `Ctrl+J` / `Ctrl+K` | Next / previous result |
| Completion popup with multiple suggestions | `Ctrl+J` / `Ctrl+K` | Next / previous suggestion |
| Completion popup with multiple suggestions | `Ctrl+L` | Accept selected suggestion |
| Parameter hints with multiple signatures | `Ctrl+J` / `Ctrl+K` | Next / previous signature |
| Code-action menu | `Ctrl+J` / `Ctrl+K` | Next / previous action |
| File Browser | `Ctrl+H` / `Ctrl+L` | Parent directory / enter directory |

**Existing caveat:** the code-action menu also binds `Ctrl+L`, but it currently dispatches `acceptSelectedSuggestion`, not a code-action acceptance command. It is not documented here as a working “accept code action” shortcut.

### VSpaceCode Magit buffer

These apply inside Magit text buffers, not ordinary files. The first four are disabled while VSCodeVim is in search/command-line entry modes; `y` is normal-mode only.

| Keys | Action |
|---|---|
| `x` | Discard at point |
| `-` | Reverse at point |
| `Shift+-` (`_` on a US layout) | Reverting menu |
| `Shift+O` | Resetting menu |
| `y` | VSpaceCode Magit references menu |

The configuration removes the conflicting Magit defaults on `k`, `v`, `Shift+V`, `Shift+X`, and the `Ctrl+U x` hard-reset chord. These are removals, not additional shortcuts.

### Neovim navigation and tools

| Keys | Action | Context |
|---|---|---|
| `SPC s h` | Search help | N |
| `SPC s k` | Search keymaps | N |
| `SPC s r` | Resume previous picker | N; **not** references |
| `SPC s /` | Grep open buffers | N |
| `SPC s d` | Search diagnostics | N |
| `SPC p p` | Project picker | N |
| `SPC b B` | Pick buffers across all workspaces | N |
| `[b` / `]b` | Previous / next buffer | N |
| `SPC b c` | Close buffer with save/discard/cancel prompt | N |
| `SPC b D` | Force-delete buffer | N; can discard changes |
| `SPC b u` | Reopen alternate/last buffer | N; unlike VSpaceCode's “reopen closed editor” |
| `SPC o s` | Toggle split terminal | N |
| `SPC o u` | Toggle undo tree | N |
| `gd` / `gr` | Definition / references | N, attached LSP |
| `gI` / `gD` | Implementation / declaration | N, attached LSP; declaration is not definition |
| `K` | Hover documentation | N, attached LSP |
| `SPC d s` / `SPC w s` | Document / workspace symbols | N, attached LSP; VSpaceCode's inherited `SPC w s` splits below |
| `[d` / `]d` | Previous / next diagnostic | N, current buffer |
| `[e` / `]e` | Previous / next error | N, current buffer |
| `Escape` | Clear search highlighting | N |
| `Escape` | Leave terminal input mode | Built-in terminal |

Neovim's native editing plugins also differ from VSCodeVim: for example, `x` deletes without yanking, and `s` is a substitute operator rather than stock Vim's substitute-and-insert action. Leader alignment does not make all native editing commands identical.

### Neovim workspace marks and REPL

| Keys | Action | Mode |
|---|---|---|
| `SPC p m 1` … `SPC p m 9` | Jump to workspace mark 1–9 | N |
| `SPC p m m` | Open Arrow marks menu | N |
| `SPC p m t` | Toggle current file's mark | N |
| `SPC p m n` / `SPC p m p` | Next / previous mark | N |
| `SPC r l` | Send current line to Slime/REPL | N |
| `SPC r s` | Send selected code to Slime/REPL | V |
| `SPC r c` | Configure Slime target | N; currently uses Zellij |

Marks moved out of `SPC w …`; REPL actions moved out of `SPC c …`. In particular, visual `SPC c r` **never sends code to a REPL**.

For the plugin-by-plugin Neovim reference (debugger, notes, AI, database, completion, and other plugin actions), see `docs/keybinds.md` in the matching `nixcat-nvim` checkout. The [published reference](https://github.com/rft/nixcat-nvim/blob/main/docs/keybinds.md) may lag unpublished local edits.

## Niri window manager

Source: [`config/niri/config.kdl`](../config/niri/config.kdl). Only active bindings are listed; commented examples such as `Mod+Tab`, touchpad-scroll volume control, and keyboard-layout switching are **not enabled**.

### Launchers, menus, and overview

| Keys | Action |
|---|---|
| `Mod+Shift+Slash` | Show hotkey overlay (often `Super+?`) |
| `Mod+Return` / `Mod+T` | Launch Kitty terminal |
| `Mod+Space` | Rofi application launcher (`drun`) |
| `Mod+P` | Rofi window switcher |
| `Mod+Q` | Launch Helium browser |
| `Ctrl+Space` | Kando “Noctalia Menu” |
| `Mod+Shift+W` | Kando “Window Menu” |
| `Mod+Shift+S` | Kando “Screenshot Menu” |
| `Mod+M` | Kando “Media Menu” |
| `Mod+X` | Kando “Power Menu” |
| `Mod+O` | Toggle overview; key repeat disabled |

The config also notes the top-left hot corner and four-finger upward touchpad swipe as ways to open overview; these are not additional keyboard bindings.

### Focus and movement

| Focus | Move | Direction / object |
|---|---|---|
| `Mod+H` / `Mod+Left` | `Mod+Ctrl+H` / `Mod+Ctrl+Left` | Left column |
| `Mod+J` / `Mod+Down` | `Mod+Ctrl+J` / `Mod+Ctrl+Down` | Window down within column |
| `Mod+K` / `Mod+Up` | `Mod+Ctrl+K` / `Mod+Ctrl+Up` | Window up within column |
| `Mod+L` / `Mod+Right` | `Mod+Ctrl+L` / `Mod+Ctrl+Right` | Right column |
| `Mod+Home` | `Mod+Ctrl+Home` | First column / move column to first |
| `Mod+End` | `Mod+Ctrl+End` | Last column / move column to last |

### Monitors

Movement below transfers the **whole column**, not just one window.

| Focus monitor | Move column to monitor | Direction |
|---|---|---|
| `Mod+Shift+H` / `Mod+Shift+Left` | `Mod+Shift+Ctrl+H` / `Mod+Shift+Ctrl+Left` | Left |
| `Mod+Shift+J` / `Mod+Shift+Down` | `Mod+Shift+Ctrl+J` / `Mod+Shift+Ctrl+Down` | Down |
| `Mod+Shift+K` / `Mod+Shift+Up` | `Mod+Shift+Ctrl+K` / `Mod+Shift+Ctrl+Up` | Up |
| `Mod+Shift+L` / `Mod+Shift+Right` | `Mod+Shift+Ctrl+L` / `Mod+Shift+Ctrl+Right` | Right |

### Workspaces

| Keys | Action |
|---|---|
| `Mod+Page_Down` / `Mod+U` | Focus workspace below |
| `Mod+Page_Up` / `Mod+I` | Focus workspace above |
| `Mod+Ctrl+Page_Down` / `Mod+Ctrl+U` | Move column to workspace below |
| `Mod+Ctrl+Page_Up` / `Mod+Ctrl+I` | Move column to workspace above |
| `Mod+Shift+Page_Down` / `Mod+Shift+U` | Move/reorder the workspace downward |
| `Mod+Shift+Page_Up` / `Mod+Shift+I` | Move/reorder the workspace upward |
| `Mod+1` … `Mod+9` | Focus workspace 1–9 |
| `Mod+Ctrl+1` … `Mod+Ctrl+9` | Move column to workspace 1–9 |

Workspace indices are dynamic. An index beyond the existing workspace count selects the bottommost empty workspace, rather than creating enough workspaces to reach that number.

### Mouse wheel

Scroll directions follow the configured natural-scroll setting. The vertical workspace bindings have a 150 ms cooldown.

| Keys | Action |
|---|---|
| `Mod+WheelScrollDown` / `Mod+WheelScrollUp` | Focus workspace below / above |
| `Mod+Ctrl+WheelScrollDown` / `Mod+Ctrl+WheelScrollUp` | Move column to workspace below / above |
| `Mod+WheelScrollRight` / `Mod+WheelScrollLeft` | Focus column right / left |
| `Mod+Ctrl+WheelScrollRight` / `Mod+Ctrl+WheelScrollLeft` | Move column right / left |
| `Mod+Shift+WheelScrollDown` / `Mod+Shift+WheelScrollUp` | Focus column right / left |
| `Mod+Ctrl+Shift+WheelScrollDown` / `Mod+Ctrl+Shift+WheelScrollUp` | Move column right / left |

### Columns, sizing, and floating windows

| Keys | Action |
|---|---|
| `Mod+BracketLeft` / `Mod+BracketRight` | Move focused window into/out of the column on the left / right |
| `Mod+Comma` | Consume a window from the right into the bottom of this column |
| `Mod+Period` | Expel the bottom window into a column to the right |
| `Mod+W` | Toggle tabbed column display |
| `Mod+R` | Cycle preset column widths |
| `Mod+Shift+R` | Cycle preset window heights |
| `Mod+Ctrl+R` | Reset window height |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+Ctrl+F` | Expand column into available width |
| `Mod+C` | Center focused column |
| `Mod+Ctrl+C` | Center all fully visible columns |
| `Mod+Minus` / `Mod+Equal` | Decrease / increase column width by 10% of screen width |
| `Mod+Shift+Minus` / `Mod+Shift+Equal` | Decrease / increase window height by 10% |
| `Mod+V` / `Mod+Ctrl+Space` | Toggle focused window between floating and tiling |
| `Mod+Shift+V` | Switch focus between floating and tiling layouts |

### Screenshots, media, and accessibility

| Keys | Action | While locked? |
|---|---|---|
| `Print` | Interactive screenshot | No |
| `Ctrl+Print` | Screenshot screen | No |
| `Alt+Print` | Screenshot window | No |
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` | Raise / lower default output volume by 0.1 (10 percentage points) | Yes |
| `XF86AudioMute` | Toggle default output mute | Yes |
| `XF86AudioMicMute` | Toggle default microphone mute | Yes |
| `XF86AudioPlay` | Play/pause via playerctl | Yes |
| `XF86AudioStop` | Stop playback | Yes |
| `XF86AudioPrev` / `XF86AudioNext` | Previous / next track | Yes |
| `XF86MonBrightnessUp` / `XF86MonBrightnessDown` | Raise / lower backlight brightness by 10% | Yes |
| `Super+Alt+S` | Toggle Orca screen reader | Yes; omitted from hotkey overlay |

`XF86…` names are hardware media/brightness keys. `Minus`, `Equal`, `BracketLeft`, `BracketRight`, `Comma`, `Period`, and `Slash` are XKB names for punctuation keys; physical positions depend on the keyboard layout.

### Closing, locking, and session control

| Keys | Action |
|---|---|
| `Mod+Shift+C` | Close focused window; key repeat disabled |
| `Super+Alt+L` | Lock screen through Noctalia |
| `Mod+Shift+P` | Power off monitors; input wakes them |
| `Mod+Shift+E` / `Ctrl+Alt+Delete` | Quit Niri with confirmation |
| `Mod+Shift+Q` | **Quit Niri immediately, without confirmation** |
| `Mod+Escape` | Toggle the application's keyboard-shortcut inhibitor; this binding cannot itself be inhibited |

## Conflicts and safety

- **`Ctrl+Space` belongs to Niri's Kando launcher.** It can intercept editor shortcuts such as Neovim's completion trigger before the editor receives them. This document does not change that binding.
- Plain `SPC` starts an editor leader sequence; `Mod+Space` launches a desktop application. They are different layers.
- **Niri `Mod+Q` opens the browser; `Mod+Shift+Q` terminates the session.** Use `Mod+Shift+C` to close one application window.
- Editor `SPC w …` actions affect splits inside the application, not Niri columns or monitors.
- Neovim `SPC b D` force-deletes a buffer; Magit `x` discards changes. Treat them as destructive, not navigation.
- `Mod+Escape` is an escape hatch for application-requested shortcut inhibition (for example a remote-desktop client), not a universal “turn off all Niri shortcuts” switch.
- Disabled examples in the KDL file are not defaults to rely on. In particular, `Mod+Tab` is not configured.

## Sources and deployment

- [Niri bindings](../config/niri/config.kdl): the active `binds` block is authoritative.
- [Niri module](../modules/desktop/niri.nix): installs the live configuration link.
- [VSpaceCode configuration](../modules/editors/vscode.nix): leader overrides, VSCodeVim integration, popup and Magit bindings. Unoverridden menu entries come from the installed VSpaceCode extension.
- [Editor module reference](MODULES.md#editorsvscode): enablement and package integration.
- Neovim checkout: `/home/nano/projects/nixcat-nvim`; its `lua/core/keymaps.lua`, `lua/plugins/`, and `docs/keybinds.md` own the complete plugin-specific layout.

### Local Neovim checkout

Until the edited Neovim revision is published and `flake.lock` is updated, apply both local editor configurations on sequoia using:

```sh
sudo nixos-rebuild switch --flake .#sequoia \
  --override-input nixcats-nvim path:/home/nano/projects/nixcat-nvim \
  --no-write-lock-file
```

An ordinary rebuild without the override still selects the published Neovim revision in `flake.lock`, not the local checkout. Nothing in this document activates a configuration or changes a keybinding.

When updating bindings, change the owning configuration first, then update the relevant table here. Keep the full Neovim plugin reference in its own repository rather than duplicating all plugin defaults in this one.
