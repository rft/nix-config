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
      helix
      solvespace
      imhex
      ghidra
      # imagej
      fiji
      cutter
      kicad
      alloy6
      # bioawk
      chirp
      pulseview
      sdrangel
      # zed-editor
      # openems
      qemu
      virt-manager
    ];
  };
}
