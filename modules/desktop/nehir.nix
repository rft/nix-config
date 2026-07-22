{ delib, ... }:
delib.module {
  name = "desktop.nehir";

  options = delib.singleEnableOption false;

  # Nehir is a macOS-only Swift scrolling tiling WM (Niri column paradigm).
  # No Nix package exists — install the Homebrew cask from guria/tap.
  darwin.ifEnabled = {
    homebrew.taps = [ "guria/tap" ];
    homebrew.casks = [ "guria/tap/nehir" ];
  };
}
