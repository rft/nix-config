{ delib, lib, pkgs, ... }:
delib.module {
  name = "applications.creative";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.creative.enable = lib.mkDefault (myconfig.applications.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      aseprite
      blender
      kdePackages.kdenlive
      krita
      reaper
    ];
  };

  darwin.ifEnabled = { };
}
