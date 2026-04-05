{ delib, inputs, ... }:
delib.overlayModule {
  name = "nur";
  overlay = inputs.nur.overlays.default;
}
