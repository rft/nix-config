{ delib, ... }:
delib.module {
  name = "applications.creative";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    applications.creative.enable = myconfig.applications.enable or false;
  };

  nixos.ifEnabled = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      aseprite
      blender
      kdePackages.kdenlive
      krita
      reaper
    ];
  };
}
