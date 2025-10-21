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

  # Disable non-core modules for mistletoe
  modules = {
    applications.enable = false;
    desktop.enable = false;
    programming = {
      enable = true;
      analysis.enable = true;
      cloud.enable = true;
    };
  };

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

  # System state version
  system.stateVersion = "25.05";
}
