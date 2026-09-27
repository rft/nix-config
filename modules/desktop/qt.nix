{ delib, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  # kdeglobals wants "r,g,b" rather than hex.
  rgb = hex: lib.concatMapStringsSep "," (i: toString (lib.fromHexString (builtins.substring i 2 hex))) [ 1 3 5 ];

  # One KColorScheme group; everything but the backgrounds is shared.
  group = { bg, alt ? bg, fg ? t.brightAluminum }: lib.mapAttrs (_: rgb) {
    BackgroundNormal = bg;
    BackgroundAlternate = alt;
    ForegroundNormal = fg;
    ForegroundInactive = t.dimAluminum;
    ForegroundActive = t.electricBlue;
    ForegroundLink = t.electricBlue;
    ForegroundVisited = t.titaniumGold;
    ForegroundNegative = t.alertRed;
    ForegroundNeutral = t.warningAmber;
    ForegroundPositive = t.readoutGreen;
    DecorationFocus = t.electricBlue;
    DecorationHover = t.electricBlue;
  };
in
delib.module {
  name = "desktop.qt";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.qt.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  # Qt/KDE apps (dolphin) outside Plasma: the KDE platform theme reads its
  # palette from kdeglobals, which we fill with the titanium palette shared
  # with noctalia, rofi, nvim, yazi and zellij.
  home.ifEnabled = {
    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "breeze";
      # Written with kwriteconfig6 on activation, so kdeglobals stays writable.
      kde.settings.kdeglobals = {
        General.ColorScheme = "Titanium";
        Icons.Theme = "breeze-dark";
        "Colors:Window" = group { bg = t.brushedTitanium; };
        "Colors:View" = group { bg = t.brushedTitanium; alt = t.borderMuted; };
        "Colors:Button" = group { bg = t.subtleGray; alt = t.slate; };
        "Colors:Selection" = group { bg = t.deepBlue; alt = t.deepBlue; };
        "Colors:Tooltip" = group { bg = t.darkTitanium; };
        "Colors:Header" = group { bg = t.darkTitanium; };
        "Colors:Complementary" = group { bg = t.darkTitanium; };
        WM = lib.mapAttrs (_: rgb) {
          activeBackground = t.darkTitanium;
          activeForeground = t.brightAluminum;
          inactiveBackground = t.darkTitanium;
          inactiveForeground = t.dimAluminum;
        };
      };
    };

    home.packages = [ pkgs.kdePackages.breeze-icons ];
  };
}
