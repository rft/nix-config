{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
  ];
  environment.systemPackages = with pkgs; [
    hy
    elixir
    julia
    swiProlog
    crystal
    zig
    rustc
    rustup
    rustfmt
    mercury
    idris2
    gleam
    nim
    futhark
    go
    j
    uiua
    supercollider
    coconut
    nodejs_22
    agda
    coq


    # Supporting Tools
    nixfmt-rfc-style

    # Python Packages
    (python312.withPackages (ps: with ps; [
        beautifulsoup4
        polars
        pandas
        numpy
        matplotlib
        simpy
        ortools
    ]))

  ];
}
