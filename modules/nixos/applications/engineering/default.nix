{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    solvespace
    imhex
    ghidra
    # imagej
    fiji
    cutter
    kicad
    alloy6
    tlaps
    tlaplusToolbox
    aflplusplus
    bioawk
    chirp
    pulseview
    sdrangel

  ];
}
