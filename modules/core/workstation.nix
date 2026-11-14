{
  delib,
  lib,
  pkgs,
  ...
}:
let
  sharedPackages = with pkgs; [
    aria2
    ffmpeg-headless
    pandoc
    pass
    rink
    syncthing
    tio
    visidata
    yt-dlp
  ];

  linuxOnlyPackages = with pkgs; [
    distrobox
    wl-clipboard
    picat
  ];
in
delib.module {
  name = "core.workstation";

  options = delib.singleEnableOption false;

  # On for machines someone sits at (desktops, WSL, Macs), off for servers
  # and the installer ISO. Besides the packages below, this is the default
  # for the GUI editors, kitty and the data-science Python set in xonsh — a
  # host can still switch any of those on or off individually.
  myconfig.always =
    { myconfig, ... }:
    {
      core.workstation.enable = lib.mkDefault (!(myconfig.host.isServer || myconfig.host.isInstaller));
    };

  nixos.ifEnabled = {
    environment.systemPackages = sharedPackages ++ linuxOnlyPackages;
  };

  darwin.ifEnabled = {
    environment.systemPackages = sharedPackages;
  };
}
