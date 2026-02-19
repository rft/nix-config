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
        confirm_os_window_close = 0;
        confirm_on_quit = 0;
      };
      extraConfig = ''
        map ctrl+shift+h kitten hints
        map ctrl+shift+i launch --type=overlay --cwd=current sh -lc 'file=$(rg --files --hidden --follow -g "!**/.git/**" . | fzf --height 80% --reverse --prompt "icat> "); [ -n "$file" ] && kitty +kitten icat "$file"'
        map ctrl+shift+c kitten clipboard
        map ctrl+shift+g kitten hyperlinked_grep
      '';
    };
  };
}
