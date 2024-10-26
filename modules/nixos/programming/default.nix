{
  config,
  lib,
  pkgs,
  ...
}:
{
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
    python311Packages.opencv4
    python311Packages.fastapi
    python311Packages.pydantic
    python311Packages.beautifulsoup4
    python311Packages.polars
  ];
}
