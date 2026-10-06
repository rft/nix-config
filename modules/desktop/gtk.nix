{ delib, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  # adw-gtk3 and libadwaita both build their widgets from these named colors,
  # so redefining them recolours GTK3 and GTK4 apps alike.
  colors = {
    accent_color = t.electricBlue;
    accent_bg_color = t.deepBlue;
    accent_fg_color = t.brightAluminum;
    destructive_color = t.alertRed;
    destructive_bg_color = t.alertRed;
    destructive_fg_color = t.brightAluminum;
    success_color = t.readoutGreen;
    warning_color = t.warningAmber;
    error_color = t.alertRed;
    window_bg_color = t.brushedTitanium;
    window_fg_color = t.brightAluminum;
    view_bg_color = t.brushedTitanium;
    view_fg_color = t.brightAluminum;
    headerbar_bg_color = t.darkTitanium;
    headerbar_fg_color = t.brightAluminum;
    headerbar_backdrop_color = t.darkTitanium;
    headerbar_border_color = t.subtleGray;
    sidebar_bg_color = t.darkTitanium;
    sidebar_fg_color = t.brightAluminum;
    sidebar_backdrop_color = t.darkTitanium;
    card_bg_color = t.borderMuted;
    card_fg_color = t.brightAluminum;
    dialog_bg_color = t.darkTitanium;
    dialog_fg_color = t.brightAluminum;
    popover_bg_color = t.darkTitanium;
    popover_fg_color = t.brightAluminum;
  };

  css = lib.concatStrings (lib.mapAttrsToList (name: hex: "@define-color ${name} ${hex};\n") colors);
in
delib.module {
  name = "desktop.gtk";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.gtk.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  # home-manager writes the color-scheme preference through dconf, which
  # needs the system dconf service.
  nixos.ifEnabled.programs.dconf.enable = true;

  # Without a desktop portal, apps (vscodium, helium, ...) draw their own GTK
  # file pickers and message boxes, which fall back to light Adwaita. Dark
  # adw-gtk3 plus the titanium palette matches them to the Qt side (qt.nix).
  home.ifEnabled.gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    gtk3.extraCss = css;
    # libadwaita ignores GTK themes; the colour overrides alone carry it.
    gtk4.theme = null;
    gtk4.extraCss = css;
  };
}
