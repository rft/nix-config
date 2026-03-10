{ delib, ... }:
delib.module {
  name = "desktop.awesome";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.awesome.enable = myconfig.desktop.enable or false;
  };

  nixos.ifEnabled = { pkgs, ... }: {
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
