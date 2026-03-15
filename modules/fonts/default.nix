{ delib, lib, pkgs, ... }:
let
  sharedFonts = with pkgs; [
    fira-code-symbols
    inter
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
in
delib.module {
  name = "fonts";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    fonts.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  nixos.ifEnabled = {
    fonts.packages = sharedFonts;
    fonts.fontconfig.defaultFonts = {
      serif = [ "Inter" ];
      sansSerif = [ "Inter" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
    };
  };

  darwin.ifEnabled = {
    fonts.packages = sharedFonts;
  };

  home.ifEnabled = {
    fonts.fontconfig.enable = true;
  };
}
