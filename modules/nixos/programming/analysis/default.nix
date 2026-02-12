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
  config = lib.mkIf (cfg.enable && cfg.analysis.enable) {
    environment.systemPackages = with pkgs; [
      # objdump
      # readelf
      # strings
      aflplusplus
      binwalk
      file
      tlaplusToolbox
      tlaps
    ];
  };
}
