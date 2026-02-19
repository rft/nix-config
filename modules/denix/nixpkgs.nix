{ delib, inputs, ... }:
delib.module {
  name = "nixpkgs";

  nixos.always = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (import ../../overlays/unstable { inherit inputs; })
        (import ../../overlays/xxh { })
        inputs.nur.overlays.default
        inputs.nix-vscode-extensions.overlays.default
      ];
    };
  };

  home.always = {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (import ../../overlays/unstable { inherit inputs; })
        (import ../../overlays/xxh { })
        inputs.nur.overlays.default
        inputs.nix-vscode-extensions.overlays.default
      ];
    };
  };
}
