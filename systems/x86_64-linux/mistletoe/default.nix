{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../../modules/nixos/core
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = "nano";

  # Basic networking
  networking.hostName = "mistletoe";

  # System state version
  system.stateVersion = "25.05";
}
