{ delib, lib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    binwalk
    file
    tlaps
  ];
in
delib.module {
  name = "programs.programming.analysis";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    programs.programming.analysis.enable = lib.mkDefault (myconfig.programs.programming.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ (with pkgs; [
      aflplusplus
      tlaplusToolbox
    ]);
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
