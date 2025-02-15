{
  pkgs,
  lib,
  config,
  ...
}:
{
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 3;
      };
    };
}
