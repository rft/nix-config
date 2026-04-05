{ delib, inputs, ... }:
delib.overlayModule {
  name = "vscode-extensions";
  overlay = inputs.nix-vscode-extensions.overlays.default;
}
