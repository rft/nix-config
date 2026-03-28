{ delib, lib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    binwalk
    file
    tlaps
  ];
  linuxPackages = with pkgs; [
    aflplusplus
    tlaplusToolbox
  ];
in
delib.module {
  name = "programs.programming.analysis";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    programs.programming.analysis.enable = lib.mkDefault (myconfig.programs.programming.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ linuxPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
