{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    modules.home.fonts.enable = lib.mkEnableOption "home fonts module";
  };

  config = lib.mkIf config.modules.home.fonts.enable {
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
