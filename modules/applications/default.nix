{ delib, pkgs, ... }:
delib.module {
  name = "applications";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      anki
      audacity
      calibre
      discord
      flameshot
      floorp-bin
      kdePackages.dolphin
      kitty
      mpv
      nsxiv
      obs-studio
      ollama
      pciutils
      plover.dev
      rofi
      spotify
    ];
  };

  darwin.ifEnabled = {
    environment.systemPackages = with pkgs; [
      kitty
      mpv
      ollama
    ];
  };
}
