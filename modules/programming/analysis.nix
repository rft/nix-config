{ delib, ... }:
delib.module {
  name = "programs.programming.analysis";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    programs.programming.analysis.enable = myconfig.programs.programming.enable or false;
  };

  nixos.ifEnabled = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      aflplusplus
      binwalk
      file
      tlaplusToolbox
      tlaps
    ];
  };
}
