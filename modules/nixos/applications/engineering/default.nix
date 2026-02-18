{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  cfg = config.modules.applications;
in
{
  config = lib.mkIf (cfg.enable && cfg.engineering.enable) {
    environment.systemPackages = with pkgs; [
      # imagej
      # openems
      alloy6
      chirp
      cutter
      fiji
      ghidra
      imhex
      kicad
      pulseview
      qemu
      sdrangel
      solvespace
      virt-manager
    ];
  };
}
