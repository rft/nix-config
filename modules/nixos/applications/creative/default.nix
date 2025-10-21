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
    environment.systemPackages = with pkgs; [
      # Creative programs
      blender
      godot_4
      krita
      aseprite
      reaper
      davinci-resolve
      inkscape
    ];
  };
}
