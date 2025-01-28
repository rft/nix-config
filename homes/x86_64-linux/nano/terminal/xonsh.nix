{ pkgs, config, ... }:
{
  home = {
    file = {
      xonsh = {
        source = ./xonsh/rc.xsh;
        target = ".config/xonsh/rc.xsh";
      };
    };
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
