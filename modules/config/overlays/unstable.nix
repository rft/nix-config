{ delib, inputs, ... }:
delib.overlayModule {
  name = "unstable";
  overlays = [
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
    (_final: prev: {
      inherit (prev.unstable) vscodium helix claude-code codex kando llama-cpp colima docker-client lima;
    })
  ];
}
