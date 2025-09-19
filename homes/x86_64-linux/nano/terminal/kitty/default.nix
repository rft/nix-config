{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.home.terminal.enable {
    programs.kitty = {
    enable = true;
    settings = {
      cursor_trail = 3;
      font_family = "FiraCode Nerd Font";

      bold_font = "FiraCode Bold Nerd Font";
      italic_font = "FiraCode Italic Nerd Font";
      bold_italic_font = "FiraCode Bold Italic Nerd Font";
    };
  };
  };
}
