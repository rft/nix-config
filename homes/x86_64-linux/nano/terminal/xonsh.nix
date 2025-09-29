{ pkgs, config, lib, ... }:
{
  config = lib.mkIf config.modules.home.terminal.enable {
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
  };
}
