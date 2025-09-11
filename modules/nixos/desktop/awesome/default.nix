{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autorandr
    arandr
  ];
  services.xserver = {
    enable = true;
    windowManager = {
      awesome = {
        enable = true;
        package = pkgs.awesome;
      };
    };
    displayManager.startx.enable = true;
  };
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
}
