{ delib, lib, pkgs, ... }:
delib.module {
  name = "fonts";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    fonts.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  home.ifEnabled = {
    home.packages = with pkgs; [
      fira-code-symbols
      inter
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "inter" ];
        sansSerif = [ "inter" ];
        monospace = [ "fira-code" ];
      };
    };
  };
}
