{ config, pkgs, ... }: {
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

  };
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
}
