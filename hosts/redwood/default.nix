{ delib, ... }:
delib.host {
  name = "redwood";
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
        creative.enable = true;
        engineering.enable = true;
      };
      desktop.enable = true;
      programming.enable = true;
    };
  };
}
