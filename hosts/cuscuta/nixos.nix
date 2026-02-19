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
  environment.systemPackages = [ pkgs.nushell ];

  # Basic networking
  networking.hostName = "cuscuta";

  # Use nushell for this host instead of the default xonsh
  users.defaultUserShell = lib.mkForce "${pkgs.nushell}/bin/nu";

  # System state version
  system.stateVersion = "25.05";
}
