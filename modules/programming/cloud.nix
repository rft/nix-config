{ delib, pkgs, ... }:
delib.module {
  name = "programs.programming.cloud";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      google-cloud-sdk
      terraform
    ];
  };
}
