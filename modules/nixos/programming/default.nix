{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    modules.programming.enable = lib.mkEnableOption "programming module";
  };

  config = lib.mkIf config.modules.programming.enable {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    environment.systemPackages = with pkgs; [
      hy
      elixir
      julia
      swi-prolog
      zig
      rustc
      rustup
      rustfmt
      mercury
      idris2
      gleam
      nim
      go
      uiua
      supercollider
      coconut
      nodejs_22
      agda
      coq

      # Supporting Tools
      nixfmt-rfc-style
      nixd
      direnv
      plantuml-c4

      # Python Packages
      (python312.withPackages (
        ps: with ps; [
          # TODO: Sort these out
          #jupyter
          beautifulsoup4
          polars
          pandas
          numpy
          matplotlib
          #simpy
          #ortools
          ipython
          ipdb

          tqdm
          #pydantic
          #requests
          # scipy
          #torch
          #jax
          #scikit-learn
          #scikit-image
          manim
          distributed
          #fastapi
          #matplotlib
          #        (ps.buildPythonPackage rec {
          #            pname = "build123d";
          #            version = "0.8.0";
          #            src = pkgs.fetchPypi {
          #                inherit pname version;
          #                sha256 = "fDbm7YynFxhzNuJjWOmAI8KvN6mlX7Mla9WCUlSe374=";
          #            };
          #        })

        ]
      ))

    ];
  };
}
