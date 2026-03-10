{ delib, inputs, ... }:
delib.module {
  name = "programs.programming";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = { pkgs, ... }: {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    environment.systemPackages = with pkgs; [
      direnv
      nixd
      nixfmt-rfc-style
      nodejs_22
      plantuml-c4
      swi-prolog
      (python312.withPackages (ps: import ../../lib/python-core-packages.nix ps))
    ];
  };
}
