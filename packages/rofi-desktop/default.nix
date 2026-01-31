{
  lib,
  inputs,
  namespace,
  pkgs,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  runtimeShell,
  python3 ? pkgs.python3,
  gtk3,
  glib,
  gdk-pixbuf,
  pango,
  atk,
  wrapGAppsHook3,
  ...
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pygobject3
    dbus-python
    xlib
  ]);

  giTypelibPath = lib.makeSearchPathOutput "lib" "lib/girepository-1.0" [
    gtk3
    gdk-pixbuf
    glib
    pango
    atk
  ];
in

stdenvNoCC.mkDerivation rec {
  pname = "rofi-desktop";
  version = "unstable-2025-10-06";

  src = fetchFromGitHub {
    owner = "giomatfois62";
    repo = "rofi-desktop";
    rev = "878e415f99017f10a9684f6269bdd489dc6b4ecc";
    hash = "sha256-cwtGLQJBG8ORg051CS5fUdS5sFT4a3HfiiTP1/mcfiM=";
  };

  dontBuild = true;
  doCheck = false;

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    glib
  ];

  installPhase = ''
    runHook preInstall

    installDir=$out/share/${pname}
    mkdir -p "$installDir" "$out/bin"

    cp -r --no-preserve=mode,ownership \
      applications \
      config.rasi \
      create-desktop-entries.sh \
      drun.sh \
      gallery \
      README.md \
      scripts \
      start.sh \
      themes \
      thumbnailers \
      "$installDir"

    find "$installDir" -type f -name '*.sh' -exec chmod +x {} +
    find "$installDir" -type f -name '*.py' -exec chmod +x {} + || true

    substituteInPlace "$installDir/scripts/rofi-search.sh" \
      --replace 'initial_path="/home/mat"' 'initial_path="''${ROFI_DESKTOP_INITIAL_PATH:-$HOME}"'

    cat > "$installDir/scripts/appmenu-service.py" <<'EOF'
#!/usr/bin/env python3

import gi

try:
    gi.require_version('Gtk', '3.0')
except ValueError as e:
    raise SystemExit(f"Failed to load Gtk 3 typelib: {e}.\n"
                     "Ensure GTK typelibs are available and GI_TYPELIB_PATH is set appropriately.")

from gi.repository import Gtk
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop


class AppmenuService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('com.canonical.AppMenu.Registrar', bus=dbus.SessionBus())
        super().__init__(bus_name, '/com/canonical/AppMenu/Registrar')
        self.window_dict = {}

    @dbus.service.method('com.canonical.AppMenu.Registrar', in_signature='uo', sender_keyword='sender')
    def RegisterWindow(self, windowId, menuObjectPath, sender):
        self.window_dict[windowId] = (sender, menuObjectPath)

    @dbus.service.method('com.canonical.AppMenu.Registrar', in_signature='u', out_signature='so')
    def GetMenuForWindow(self, windowId):
        entry = self.window_dict.get(windowId)
        if entry:
            sender, menuObjectPath = entry
            return [dbus.String(sender), dbus.ObjectPath(menuObjectPath)]

        raise dbus.exceptions.DBusException(
            'com.canonical.AppMenu.Registrar.Error.WindowNotFound',
            f"No menu registered for window {windowId}"
        )

    @dbus.service.method('com.canonical.AppMenu.Registrar')
    def Q(self):
        Gtk.main_quit()


def main():
    DBusGMainLoop(set_as_default=True)
    try:
        AppmenuService()
    except dbus.DBusException as exc:
        raise SystemExit(f"Failed to register AppMenu service: {exc}")
    Gtk.main()


if __name__ == '__main__':
    main()
EOF

    makeWrapper ${runtimeShell} "$out/bin/rofi-desktop" \
      --add-flags "$installDir/scripts/rofi-desktop.sh" \
      --set ROFI_DESKTOP_HOME "$installDir"

    makeWrapper ${pythonEnv}/bin/python3 "$out/bin/rofi-desktop-hud" \
      --add-flags "$installDir/scripts/rofi-hud.py" \
      --set ROFI_DESKTOP_HOME "$installDir" \
      --prefix GI_TYPELIB_PATH : "${giTypelibPath}"

    makeWrapper ${pythonEnv}/bin/python3 "$out/bin/rofi-appmenu-service" \
      --add-flags "$installDir/scripts/appmenu-service.py" \
      --set ROFI_DESKTOP_HOME "$installDir" \
      --prefix GI_TYPELIB_PATH : "${giTypelibPath}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Collection of Rofi-powered menus for desktop workflows";
    homepage = "https://github.com/giomatfois62/rofi-desktop";
    license = licenses.unfree;
    maintainers = [ ];
    mainProgram = "rofi-desktop";
    platforms = platforms.unix;
  };
}
