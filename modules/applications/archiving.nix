{ delib, pkgs, ... }:
delib.module {
  name = "applications.archiving";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      gallery-dl
      hydrus
    ];
  };
}
