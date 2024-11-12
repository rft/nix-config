{
  pkgs,
  lib,
  config,
  ...
}:
{
  #programs.xonsh = {
  #  enable = true;
  #};
  # imports = [ ./starship.nix ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.nushell = {
    enable = true;
  };
}
