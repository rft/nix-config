{ delib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    google-cloud-sdk
    terraform
  ];
in
delib.module {
  name = "programs.programming.cloud";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
