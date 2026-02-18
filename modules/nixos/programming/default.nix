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

      # Supporting Tools
      # agda
      # cabal-install
      # coq
      # coconut
      # elixir
      # ghc
      # gleam
      # hy
      # idris2
      # julia
      # mercury
      # nim
      # rustc
      # rustfmt
      # rustup
      # stack
      # supercollider
      # uiua
      direnv
      nixd
      nixfmt-rfc-style
      nodejs_22
      plantuml-c4
      swi-prolog

      # Python Packages
      (python312.withPackages (ps: import ../../../lib/python-core-packages.nix ps))

    ];

    modules.programming.analysis.enable = lib.mkDefault true;
    modules.programming.cloud.enable = lib.mkDefault false;
  };
}
