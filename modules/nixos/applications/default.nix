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
    modules.applications.creative.enable = lib.mkEnableOption "creative tooling for the applications module";
    modules.applications.engineering.enable = lib.mkEnableOption "engineering tooling for the applications module";
  };

  imports = [
    ./creative
    ./engineering
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

      rofi
      flameshot
      ollama
      #rustdesk
      plover.dev
      obs-studio
      discord
      spotify
    ];

    modules.applications.creative.enable = lib.mkDefault true;
    modules.applications.engineering.enable = lib.mkDefault true;
  };
}
