{ pkgs, config, ... }:
{
  home = {
    packages = [
      pkgs.starship
    ];
  };
  programs = {
    fzf = {
      enable = true;
    };
  };
}
