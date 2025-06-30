{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./starship.nix
    ./xonsh.nix
    ./kitty
    ./nushell.nix
  ];

  # Probably should move this to it's own, but it's kind of small so idk
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

}
