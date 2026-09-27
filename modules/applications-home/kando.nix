{ delib, inputs, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  item = name: icon: command: {
    type = "command";
    data = { inherit command; delayed = false; };
    inherit name icon;
    iconTheme = "material-symbols-rounded";
  };

  # Runs once the menu has faded out, so actions hit the window that had focus
  # before Kando opened (and screenshots don't capture the menu itself).
  delayedItem = name: icon: command:
    lib.recursiveUpdate (item name icon command) { data.delayed = true; };

  submenu = name: icon: children: {
    type = "submenu";
    inherit name icon children;
    iconTheme = "material-symbols-rounded";
  };

  # niri has no global-shortcuts portal, so every menu is opened by a niri bind
  # running `kando --menu "<name>"` (see config/niri/config.kdl).
  menu = root: {
    shortcut = "";
    shortcutID = lib.toLower (lib.replaceStrings [ " " ] [ "-" ] root.name);
    centered = false;
    warpMouse = false;
    anchored = false;
    hoverMode = false;
    inherit root;
  };

  applications = submenu "Applications" "apps" [
    (item "Kitty Terminal" "terminal" "kitty")
    (item "Helium Browser" "public" "helium")
    (item "VSCodium" "code" "codium")
    (item "Dolphin" "folder" "dolphin")
  ];

  launchers = submenu "Launchers" "widgets" [
    (item "Rofi Apps" "search" "rofi -show drun")
    (item "Rofi Windows" "view_quilt" "rofi -show window")
    (item "Rofi Desktop" "dashboard" "rofi-desktop")
    (item "Global Menu" "menu" "rofi-desktop-hud")
  ];

  window = submenu "Window" "select_window" [
    (delayedItem "Close" "close" "niri msg action close-window")
    (delayedItem "Fullscreen" "fullscreen" "niri msg action fullscreen-window")
    (delayedItem "Float" "picture_in_picture" "niri msg action toggle-window-floating")
    (delayedItem "Maximize Column" "open_in_full" "niri msg action maximize-column")
    (delayedItem "Center Column" "center_focus_strong" "niri msg action center-column")
    (delayedItem "Move Up a Workspace" "arrow_upward" "niri msg action move-column-to-workspace-up")
    (delayedItem "Move Down a Workspace" "arrow_downward" "niri msg action move-column-to-workspace-down")
  ];

  screenshot = submenu "Screenshot" "screenshot_region" [
    (delayedItem "Region" "crop" "noctalia msg screenshot-region")
    (delayedItem "Screen" "desktop_windows" "noctalia msg screenshot-fullscreen")
    (delayedItem "Window" "web_asset" "niri msg action screenshot-window")
    (delayedItem "Annotate" "draw" "noctalia msg screenshot-annotate")
    (delayedItem "Flameshot" "photo_camera" "flameshot gui")
  ];

  media = submenu "Media" "music_note" [
    (item "Play / Pause" "play_pause" "noctalia msg media toggle")
    (item "Next" "skip_next" "noctalia msg media next")
    (item "Previous" "skip_previous" "noctalia msg media previous")
    (item "Volume Up" "volume_up" "noctalia msg volume-up")
    (item "Volume Down" "volume_down" "noctalia msg volume-down")
    (item "Mute" "volume_off" "noctalia msg volume-mute")
  ];

  power = submenu "Power" "power_settings_new" [
    (item "Lock Screen" "lock" "noctalia msg session lock")
    (item "Suspend" "bedtime" "noctalia msg session suspend")
    (item "Log Out" "logout" "noctalia msg session logout")
    (item "Reboot" "restart_alt" "noctalia msg session reboot")
    (item "Shut Down" "power_settings_new" "noctalia msg session shutdown")
  ];

  # Kando's default theme is driven entirely by these colour variables, so
  # reuse its CSS and only swap the palette.
  themeDir = "${pkgs.kando}/share/kando/resources/app/.webpack/renderer/assets/menu-themes/default";
  themeJson = {
    name = "Titanium";
    author = "nano";
    license = "CC0-1.0";
    themeVersion = "1.0";
    engineVersion = 1;
    maxMenuRadius = 160;
    centerTextWrapWidth = 95;
    drawChildrenBelow = true;
    drawSelectionWedges = true;
    colors = {
      "background-color" = t.brushedTitanium;
      "text-color" = t.brightAluminum;
      "border-color" = t.subtleGray;
      "hover-color" = t.deepBlue;
      "wedge-highlight-color" = "${t.electricBlue}33";
      "wedge-color" = "${t.darkTitanium}99";
    };
    layers = [
      { class = "quick-key"; content = "quick-select-key"; }
      { class = "icon-layer"; content = "icon"; }
    ];
  };
in
delib.module {
  name = "applications.kando";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.kando.enable = lib.mkDefault (
      (myconfig.applications.enable or false) && !pkgs.stdenv.hostPlatform.isDarwin
    );
  };

  home.ifEnabled = {
    home.packages = [ pkgs.kando ];

    systemd.user.services.kando = {
      Unit = {
        Description = "Kando radial menu";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.kando} --background";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.configFile."kando/menus.json".text = builtins.toJSON {
      menus = [
        (menu (submenu "Noctalia Menu" "apps" [ applications launchers window screenshot media power ]))
        (menu (window // { name = "Window Menu"; }))
        (menu (screenshot // { name = "Screenshot Menu"; }))
        (menu (media // { name = "Media Menu"; }))
        (menu (power // { name = "Power Menu"; }))
      ];
      templates = [ ];
    };

    xdg.configFile."kando/menu-themes/titanium/theme.css".source = "${themeDir}/theme.css";
    xdg.configFile."kando/menu-themes/titanium/theme.json5".text = builtins.toJSON themeJson;

    # config.json stays writable (Kando saves settings into it), so only these
    # keys are patched in rather than managing the whole file. menus.json is a
    # read-only store symlink, which Kando warns about unless told to ignore it.
    home.activation.kandoTheme = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cfg="$HOME/.config/kando/config.json"
      if [ -f "$cfg" ]; then
        tmp=$(mktemp)
        ${lib.getExe pkgs.jq} '.menuTheme = "titanium" | .darkMenuTheme = "titanium" | .ignoreWriteProtectedConfigFiles = true' "$cfg" > "$tmp" \
          && run mv "$tmp" "$cfg"
      else
        run mkdir -p "$(dirname "$cfg")"
        run sh -c 'echo "{\"menuTheme\": \"titanium\", \"darkMenuTheme\": \"titanium\", \"ignoreWriteProtectedConfigFiles\": true}" > "$1"' _ "$cfg"
      fi
    '';
  };
}
