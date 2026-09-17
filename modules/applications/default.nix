{ delib, pkgs, ... }:
let
  sharedPackages = with pkgs; [
    mpv
  ];

  linuxOnlyPackages = with pkgs; [
    rustdesk-flutter
    anki
    audacity
    calibre
    discord
    flameshot
    floorp-bin
    kdePackages.dolphin
    kitty
    nsxiv
    obs-studio
    pciutils
    plover
    rofi
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
