{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Creative programs
    blender
    godot_4
    krita
    aseprite
    reaper
  ];
}
