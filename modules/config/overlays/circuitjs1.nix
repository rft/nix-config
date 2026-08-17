{ delib, ... }:
delib.overlayModule {
  name = "circuitjs1";
  # Not in nixpkgs — provide Falstad's offline build as pkgs.circuitjs1.
  overlay = _final: prev: {
    circuitjs1 = prev.callPackage ../../../packages/circuitjs1 { };
  };
}
