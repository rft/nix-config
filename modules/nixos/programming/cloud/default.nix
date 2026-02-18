{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.programming;
in
{
  config = lib.mkIf (cfg.enable && cfg.cloud.enable) {
    environment.systemPackages = with pkgs; [
      google-cloud-sdk
      terraform
    ];
  };
}
