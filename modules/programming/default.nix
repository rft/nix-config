{ delib, inputs, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    direnv
    nixd
    nixfmt-rfc-style
    nodejs_22
    cucumber
    plantuml-c4
    swi-prolog
    texlab
    (python313.withPackages (ps: import ../../lib/python-core-packages.nix ps))
    (texlive.combine {
      inherit (texlive)
        scheme-medium
        latexmk
        ;
    })
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
