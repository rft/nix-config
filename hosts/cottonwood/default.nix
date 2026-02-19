{ delib, ... }:
delib.host {
  name = "cottonwood";
  system = "x86_64-linux";
  homeManagerSystem = "x86_64-linux";
  rice = "default";

  nixos = {
    imports = [
      ./nixos.nix
    ];
    modules = {
      applications.enable = true;
      desktop.enable = true;
      programming.enable = true;
    };
  };
}
