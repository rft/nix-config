{ delib, lib, pkgs, ... }:
delib.module {
  name = "applications.engineering";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.engineering.enable = lib.mkDefault (myconfig.applications.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
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
