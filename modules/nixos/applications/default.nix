{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./creative
    ./engineering
  ];

    environment.systemPackages = with pkgs; [
    kitty
    floorp
    wezterm
    pciutils

    libsForQt5.dolphin
    calibre
    mpv
    anki
    nsxiv
    audacity
    hydrus

    rofi-wayland
    #zed-editor
    flameshot
    ollama

    rustdesk
    nyxt
  ];

}
