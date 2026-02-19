{ delib, ... }:
delib.host {
  name = "mistletoe";
  system = "x86_64-linux";
  homeManagerSystem = "x86_64-linux";
  rice = "default";

  nixos = {
    imports = [
      ./nixos.nix
    ];
    modules = {
      applications.enable = false;
      desktop.enable = false;
      programming = {
        enable = true;
        analysis.enable = true;
        cloud.enable = true;
      };
    };
  };
}
