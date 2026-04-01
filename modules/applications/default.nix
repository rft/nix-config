{ delib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    kitty
    mpv
    ollama
  ];

  linuxOnlyPackages = with pkgs; [
    anki
    audacity
    calibre
    discord
    flameshot
    floorp-bin
    kdePackages.dolphin
    nsxiv
    obs-studio
    pciutils
    plover.dev
    rofi
    rustdesk-flutter
    spotify
  ];
in
delib.module {
  name = "applications";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
