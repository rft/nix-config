{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
{
  config = lib.mkIf config.modules.applications.enable {
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
      ]
      ++ [
        inputs.self.packages.${system}.plascad
        inputs.self.packages.${system}.calcpy
      ];
  };
}
