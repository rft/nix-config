{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.programming;
in
{
  options = {
    modules.programming.enable = lib.mkEnableOption "programming module";
    modules.programming.analysis.enable = lib.mkEnableOption "analysis tooling for the programming module";
    modules.programming.cloud.enable = lib.mkEnableOption "cloud tooling for the programming module";
  };

  imports = [
    ./analysis
    ./cloud
  ];

  config = lib.mkIf cfg.enable {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    environment.systemPackages = with pkgs; [
      # TODO: Commented most of the languages out, likely better to use devshells for these. Make templates later
      # hy
      # elixir
      # julia
      swi-prolog
      # rustc
      # rustup
      # rustfmt
      # mercury
      # idris2
      # gleam
      # nim
      # uiua
      # supercollider
      coconut
      nodejs_22
      # agda
      # coq
      # ghc
      # cabal-install
      # stack

      # Supporting Tools
      nixfmt-rfc-style
      nixd
      direnv
      plantuml-c4

      # Python Packages
      (python312.withPackages (
        ps: import ../../../lib/python-core-packages.nix ps
      ))

    ];

    modules.programming.analysis.enable = lib.mkDefault true;
    modules.programming.cloud.enable = lib.mkDefault false;
  };
}
