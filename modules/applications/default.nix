{
  delib,
  inputs,
  lib,
  pkgs,
  ...
}:
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
    handy
    imv
    kdePackages.dolphin
    kitty
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

  home.ifEnabled = lib.mkIf pkgs.stdenv.isLinux {
    # imv-dir opens the image with its siblings loaded, so next/prev walks the folder.
    # xdg-mime instead of xdg.mimeApps keeps mimeapps.list writable for other apps' handlers.
    home.activation.imvDefaultImageViewer =
      inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
        ''
          run ${pkgs.xdg-utils}/bin/xdg-mime default imv-dir.desktop \
            image/png image/x-png image/jpeg image/jpg image/pjpeg image/gif image/webp \
            image/avif image/heif image/jxl image/svg+xml image/bmp image/x-bmp \
            image/tiff image/tiff-fx image/qoi image/x-farbfeld
        '';
  };
}
