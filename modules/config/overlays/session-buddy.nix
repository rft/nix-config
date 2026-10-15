{ delib, ... }:
delib.overlayModule {
  name = "session-buddy";
  # Web Store extension repacked with a right-click "Save session" menu.
  overlay = _final: prev: {
    session-buddy = prev.callPackage ../../../packages/session-buddy { };
  };
}
