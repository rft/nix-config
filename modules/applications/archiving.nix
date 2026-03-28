{ delib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    gallery-dl
  ];
in
delib.module {
  name = "applications.archiving";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ (with pkgs; [
      hydrus
    ]);
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
