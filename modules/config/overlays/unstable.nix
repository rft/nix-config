{ delib, inputs, ... }:
delib.overlayModule {
  name = "unstable";
  overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
    (final: prev: {
      inherit (prev.unstable) vscodium helix claude-code codex kando;
    })
  ];
}
