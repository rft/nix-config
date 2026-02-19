{ delib, ... }:
delib.host {
  name = "myrtle";
  system = "x86_64-linux";
  homeManagerSystem = "x86_64-linux";
  rice = "default";

  nixos = {
    imports = [
      ./nixos.nix
    ];
    modules = {
      applications = {
        enable = true;
        archiving.enable = true;
        creative.enable = false;
        engineering.enable = false;
      };
      desktop.enable = true;
      programming.enable = false;
    };
  };
}
