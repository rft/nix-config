{ delib, inputs, ... }:
delib.module {
  name = "overlays";

  nixos.always.nixpkgs = {
    overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config.allowUnfree = true;
        };
      })
      (final: prev: {
        inherit (prev.unstable) vscodium helix claude-code codex kando;
      })
      (final: prev:
        let
          python3PackagesExtended = prev.python3Packages // {
            xxh = prev.python3Packages.callPackage ../../packages/xxh { };
          };
        in
        {
          python3Packages = python3PackagesExtended;
          xxh = python3PackagesExtended.xxh;
        })
      inputs.nur.overlays.default
      inputs.nix-vscode-extensions.overlays.default
    ];
    config.allowUnfree = true;
  };

  home.always.nixpkgs = {
    overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config.allowUnfree = true;
        };
      })
      (final: prev: {
        inherit (prev.unstable) vscodium helix claude-code codex kando;
      })
      (final: prev:
        let
          python3PackagesExtended = prev.python3Packages // {
            xxh = prev.python3Packages.callPackage ../../packages/xxh { };
          };
        in
        {
          python3Packages = python3PackagesExtended;
          xxh = python3PackagesExtended.xxh;
        })
      inputs.nur.overlays.default
      inputs.nix-vscode-extensions.overlays.default
    ];
    config.allowUnfree = true;
  };
}
