{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    modules.applications.enable = lib.mkEnableOption "applications module";
  };

  imports = [
    ./creative
    ./engineering
  ];

  config = lib.mkIf config.modules.applications.enable {
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
    ];
  };
}
