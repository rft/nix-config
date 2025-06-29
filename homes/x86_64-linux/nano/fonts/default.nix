{
  config,
  pkgs,
  inputs,
  ...
}:
{

  home.packages = with pkgs; [
    inter
    fira-code-symbols
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
}
