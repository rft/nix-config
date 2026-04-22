{
  delib,
  lib,
  pkgs,
  ...
}:
let
  sharedPackages = with pkgs; [
    binsider
    binwalk
    coz
    file
    hexyl
    perf
    samply
    tlaps
    valgrind
    # TODO: Add more profilers here
  ];
  linuxPackages = with pkgs; [
    aflplusplus
    tlaplusToolbox
  ];
in
delib.module {
  name = "programs.programming.analysis";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      programs.programming.analysis.enable = lib.mkDefault (
        myconfig.programs.programming.enable or false
      );
    };

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ linuxPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
