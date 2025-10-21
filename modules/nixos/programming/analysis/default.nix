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
      file
      # strings
      # readelf
      # objdump
      binwalk
      tlaps
      tlaplusToolbox
      aflplusplus
    ];
  };
}

