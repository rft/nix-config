{ delib, ... }:
delib.overlayModule {
  name = "oh-my-pi";
  # Not in nixpkgs — provide the prebuilt release binary as pkgs.oh-my-pi.
  overlay = _final: prev: {
    oh-my-pi = prev.callPackage ../../../packages/oh-my-pi { };
  };
}
