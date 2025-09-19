{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  # Manually include only core functionality, bypassing snowfall auto-imports
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../../modules/nixos/core
  ];

  # Explicitly disable any auto-imported modules we don't want
  disabledModules = [
    ../../../modules/nixos/desktop
    ../../../modules/nixos/applications
    ../../../modules/nixos/programming
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
