{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # NixOS-WSL module
    inputs.nixos-wsl.nixosModules.wsl
    # Only import core module for minimal WSL setup
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
  system.stateVersion = "24.11";
}
