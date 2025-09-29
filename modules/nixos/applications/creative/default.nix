{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.applications.enable {
    environment.systemPackages = with pkgs; [
      # Creative programs
      blender
      godot_4
      krita
      aseprite
      reaper
      davinci-resolve
    ];
  };
}
