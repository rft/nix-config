{ delib, ... }:
delib.overlayModule {
  name = "fluidcad";
  # Not in nixpkgs — packaged from the prebuilt npm release.
  overlay = _final: prev: {
    fluidcad = prev.callPackage ../../../packages/fluidcad { };
  };
}
