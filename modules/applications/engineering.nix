{
  delib,
  lib,
  pkgs,
  ...
}:
let
  sharedPackages = with pkgs; [
    fluidcad
    ghidra
    imhex
    qemu
    scanruler-mcp
  ];

  linuxOnlyPackages = with pkgs; [
    alloy6
    chirp
    fiji
    pulseview
    sdrangel
    solvespace
    virt-manager
    kicad
  ];
in
delib.module {
  name = "applications.engineering";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.engineering.enable = lib.mkDefault (myconfig.applications.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
