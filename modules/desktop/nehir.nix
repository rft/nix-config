{ delib, ... }:
delib.module {
  name = "desktop.nehir";

  options = delib.singleEnableOption false;

  # Nehir is a macOS-only Swift scrolling tiling WM (Niri column paradigm).
  # No Nix package exists — install the Homebrew cask from guria/tap.
  darwin.ifEnabled = {
    homebrew.taps = [ "guria/tap" ];
    homebrew.casks = [ "guria/tap/nehir" ];

    # Nehir has no built-in "launch at login" option, so start it via launchd.
    # The path is Homebrew's /Applications install, not a Nix store path.
    launchd.user.agents.nehir = {
      serviceConfig = {
        Label = "dev.guria.nehir";
        ProgramArguments = [ "/Applications/Nehir.app/Contents/MacOS/Nehir" ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
