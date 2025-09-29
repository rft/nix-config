{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.modules.desktop.enable {
    environment.systemPackages = with pkgs; [
      autorandr
      arandr
    ];
    services.xserver = {
      enable = true;
      windowManager = {
        awesome = {
          enable = true;
        };
      };
      displayManager.startx.enable = true;
    };
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
