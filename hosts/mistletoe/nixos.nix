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
    ../../modules/nixos/core
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = "nano";

  # Enable nix-ld for compatibility (mostly for vscode remote)
  programs.nix-ld.enable = true;

  # Basic networking
  networking.hostName = "mistletoe";

  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.05";
}
