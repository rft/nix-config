{ delib, ... }:
delib.overlayModule {
  name = "ai-usagebar";
  # Not in nixpkgs — CLI backing the noctalia ai-usagebar plugin.
  overlay = _final: prev: {
    ai-usagebar = prev.callPackage ../../../packages/ai-usagebar { };
  };
}
