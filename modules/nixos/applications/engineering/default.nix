{
  config,
  lib,
  pkgs,
  inputs,
  system,
  namespace,
  ...
}:
let
  cfg = config.modules.applications;
  inherit (inputs.self.packages.${system}.${namespace}) plascad calcpy;
in
{
  config = lib.mkIf (cfg.enable && cfg.engineering.enable) {
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
        bioawk
        chirp
        pulseview
        sdrangel
        # zed-editor
        openems
      ]
      ++ [
        plascad
        calcpy
      ];
  };
}
