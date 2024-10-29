{ config, pkgs, ... }: {
  services.xserver = {
    enable = true;
    windowManager = {
      awesome = {
        enable = true;
        package = pkgs.awesome;
      };
    };

  };
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
}
