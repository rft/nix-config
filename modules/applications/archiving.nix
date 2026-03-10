{ delib, ... }:
delib.module {
  name = "applications.archiving";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      archivebox
      galllery-dl
      hydrus
    ];
  };
}
