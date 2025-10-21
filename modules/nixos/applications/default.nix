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
  options = {
    modules.applications.enable = lib.mkEnableOption "applications module";
    modules.applications.archiving.enable =
      lib.mkEnableOption "archiving tools for the applications module";
    modules.applications.creative.enable =
      lib.mkEnableOption "creative tooling for the applications module";
    modules.applications.engineering.enable =
      lib.mkEnableOption "engineering tooling for the applications module";
  };

  imports = [
    ./creative
    ./engineering
    ../archiving
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kitty
      floorp
      # wezterm
      pciutils

      libsForQt5.dolphin
      calibre
      mpv
      anki
      nsxiv
      audacity
      hydrus

      rofi-wayland
      flameshot
      ollama
      #rustdesk
      plover
    ];

    modules.applications.archiving.enable = lib.mkDefault false;
    modules.applications.creative.enable = lib.mkDefault true;
    modules.applications.engineering.enable = lib.mkDefault true;
  };
}
