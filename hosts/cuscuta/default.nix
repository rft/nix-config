{ delib, ... }:
delib.host {
  name = "cuscuta";
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
        analysis.enable = false;
        cloud.enable = false;
      };
    };
  };
}
