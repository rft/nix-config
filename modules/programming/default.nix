{ delib, inputs, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    direnv
    nixd
    nixfmt-rfc-style
    nodejs_22
    plantuml-c4
    swi-prolog
    (python312.withPackages (ps: import ../../lib/python-core-packages.nix ps))
  ];
in
delib.module {
  name = "programs.programming";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    environment.systemPackages = sharedPackages;
  };

  darwin.ifEnabled = {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    environment.systemPackages = sharedPackages;
  };
}
