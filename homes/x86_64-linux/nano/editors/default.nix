{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace ? "internal", # The namespace used for your flake, defaulting to "internal" if not set.
  home ? null, # The home architecture for this host (eg. `x86_64-linux`).
  target ? null, # The Snowfall Lib target for this home (eg. `x86_64-home`).
  format ? null, # A normalized name for the home target (eg. `home`).
  virtual ? null, # A boolean to determine whether this home is a virtual target using nixos-generators.
  host ? null, # The host name for this home.

  # All other arguments come from the home home.
  config,
  ...
}:
{
  options = {
    modules.home.editors.enable = lib.mkEnableOption "home editors module";
  };

  imports = [
    inputs.nix-doom-emacs-unstraightened.hmModule
    ./vscode
    ./helix
  ];
  
  config = lib.mkIf config.modules.home.editors.enable {
    programs.doom-emacs = {
      enable = false;
      doomDir = ./doom.d;
    };
  };
}
