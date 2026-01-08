{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  homesLib = import ../../../lib/homes.nix { inherit lib; };
  systemHomes = homesLib.forSystem pkgs.system;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs;
      };
      users = systemHomes;
    };
  };
}
