{ delib, ... }:
delib.module {
  name = "terminal.kitty";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 3;
        font_family = "FiraCode Nerd Font Mono";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
        confirm_os_window_close = 0;
        confirm_on_quit = 0;
      };
    };
  };
}
