{ delib, ... }:
delib.module {
  name = "programs.programming.cloud";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      google-cloud-sdk
      terraform
    ];
  };
}
