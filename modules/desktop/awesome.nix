{ delib, lib, pkgs, ... }:
delib.module {
  name = "desktop.awesome";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.awesome.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      autorandr
      arandr
    ];
    services.xserver = {
      enable = true;
      windowManager.awesome.enable = true;
      displayManager.startx.enable = true;
    };
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
