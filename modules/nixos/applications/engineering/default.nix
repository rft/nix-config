{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
  ];
  environment.systemPackages =
    with pkgs;
    [
      helix
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
      # zed-editor
      openems
      claude-code
    ]
    ++ [
      inputs.self.packages.${system}.plascad
      inputs.self.packages.${system}.calcpy
    ];
}
