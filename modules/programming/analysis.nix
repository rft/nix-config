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
    file
    hexyl
    samply
    tlaps
    # TODO: Add more profilers here
  ];
  linuxPackages = with pkgs; [
    aflplusplus
    coz
    perf
    tlaplusToolbox
    valgrind
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
