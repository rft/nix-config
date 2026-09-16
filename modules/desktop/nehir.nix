{ delib, ... }:
delib.module {
  name = "desktop.nehir";

  options = delib.singleEnableOption false;

  # Nehir is a macOS-only Swift scrolling tiling WM (Niri column paradigm).
  # No Nix package exists — install the Homebrew cask from guria/tap.
  #
  # Pinned to the @rc cask, not stable. Stable is stuck at 0.5.1, where a
  # CGS space-destroy event (macOS tears down the lock-screen Space ~2s after
  # a lid-open wake) drops live windows from Nehir's model. Nehir parks hidden
  # windows just off the right screen edge, so a dropped window is stranded
  # there forever: process alive, window invisible, absent from the workspace
  # bar. Fixed upstream in 0.6.0-rc.34; the stable cask's livecheck uses
  # :github_latest and never sees prereleases. Revisit once 0.6.0 ships.
  darwin.ifEnabled = {
    homebrew.taps = [ "guria/tap" ];
    homebrew.casks = [ "guria/tap/nehir@rc" ];

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
