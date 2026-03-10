{ delib, lib, pkgs, ... }:
delib.module {
  name = "programs.programming.analysis";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    programs.programming.analysis.enable = lib.mkDefault (myconfig.programs.programming.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      aflplusplus
      binwalk
      file
      tlaplusToolbox
      tlaps
    ];
  };
}
