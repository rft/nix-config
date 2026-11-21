{ delib, ... }:
delib.overlayModule {
  name = "psd-tools";
  # psd-tools 1.12.2 (needed by hydrus, applications.archiving) has one test
  # that fails against Pillow 13: test_composite_pil[bitmap-1-1-True-False]
  # raises "ValueError: Invalid mode for data type" from Image.fromarray when
  # compositing a 1-bit bitmap. The other 976 tests pass. Not fixed on
  # nixos-26.05, nixos-unstable or master as of 2026-11-21; delete this file
  # once nixpkgs bumps psd-tools or skips the test itself.
  overlay = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pyfinal: pyprev: {
        psd-tools = pyprev.psd-tools.overridePythonAttrs (old: {
          disabledTests = (old.disabledTests or [ ]) ++ [
            "test_composite_pil[bitmap-1-1-True-False]"
          ];
        });
      })
    ];
  };
}
