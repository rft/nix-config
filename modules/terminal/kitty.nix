{ delib, ... }:
delib.module {
  name = "terminal.kitty";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 3;
        font_family = "FiraCode Nerd Font";
        bold_font = "FiraCode Bold Nerd Font";
        italic_font = "FiraCode Italic Nerd Font";
        bold_italic_font = "FiraCode Bold Italic Nerd Font";
        confirm_os_window_close = 0;
        confirm_on_quit = 0;
      };
    };
  };
}
