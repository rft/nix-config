{
  delib,
  lib,
  pkgs,
  ...
}:
let
  linuxOnlyPackages = with pkgs; [
    heroic
    lutris
    mangohud
    prismlauncher
    protonup-qt
  ];
in
delib.module {
  name = "applications.gaming";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = linuxOnlyPackages;

    programs.steam = {
      enable = lib.mkDefault true;
      # Translates X11 input events to uinput so Steam Input works under niri (Wayland).
      extest.enable = lib.mkDefault true;
      protontricks.enable = lib.mkDefault true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # Not mkDefault: programs.steam already sets this at mkDefault priority.
    programs.gamescope.enable = true;
    programs.gamemode.enable = lib.mkDefault true;
  };

  darwin.ifEnabled = {
    homebrew.casks = [ "steam" ];
  };
}
