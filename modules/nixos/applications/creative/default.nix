{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.applications;
in
{
  config = lib.mkIf (cfg.enable && cfg.creative.enable) {
    # Creative programs
    environment.systemPackages = with pkgs; [
      aseprite
      blender
      kdePackages.kdenlive
      krita
      reaper
    ];
  };
}
