{ delib, ... }:
delib.overlayModule {
  name = "oxker";
  # oxker's UI insta snapshots hardcode Linux key labels (e.g. "Alt", "Del",
  # "Backspace"), but on macOS they render as "Option", "Fwd Del", "Delete", so a
  # whole set of help/inspect snapshot tests fail during the check phase. This
  # breaks `darwin-rebuild switch` (oxker is also uncached on aarch64-darwin for
  # the same reason). nixpkgs already tries to skip a few of these via checkFlags,
  # but the names have drifted and it misses most. Rather than chase individual
  # test names, just skip the check phase on Darwin — Linux still runs the full
  # suite (and Hydra caches it), so coverage there is unchanged.
  overlay = _final: prev: {
    oxker = prev.oxker.overrideAttrs (old: {
      doCheck = old.doCheck or true && !prev.stdenv.hostPlatform.isDarwin;
    });
  };
}
