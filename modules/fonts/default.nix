{ delib, lib, pkgs, ... }:
delib.module {
  name = "fonts";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    fonts.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  nixos.ifEnabled = {
    fonts.packages = with pkgs; [
      fira-code-symbols
      inter
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fonts.fontconfig.defaultFonts = {
      serif = [ "Inter" ];
      sansSerif = [ "Inter" ];
      monospace = [ "FiraCode Nerd Font Mono" ];
    };
  };

  home.ifEnabled = {
    fonts.fontconfig.enable = true;
  };
}
