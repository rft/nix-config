{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "terminal.kitty";

  options = delib.singleEnableOption true;

  # On Darwin the app comes from Homebrew, not nixpkgs. The nixpkgs bundle's
  # Contents/MacOS/kitty is a binary wrapper that execs .kitty-wrapped in the
  # store; LaunchServices sees the exec transition and keeps only
  # originalPid/originalExecutablePath, so NSWorkspace reports the app with
  # processIdentifier -1. AX-based window managers (nehir) look an app up by
  # pid to attach their observers, so kitty is invisible to them and gets
  # dropped on every re-enumeration — after a wake it stays parked off-screen
  # at the right edge with no way to reach it. home-manager still owns
  # kitty.conf on both platforms; only the package differs.
  darwin.ifEnabled.homebrew.casks = [ "kitty" ];

  home.ifEnabled = {
    programs.kitty = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
      settings = {
        cursor_trail = 3;
        font_family = "FiraCode Nerd Font";
        bold_font = "FiraCode Bold Nerd Font";
        italic_font = "FiraCode Italic Nerd Font";
        bold_italic_font = "FiraCode Bold Italic Nerd Font";
        macos_option_as_alt = true;
        confirm_os_window_close = 0;
        confirm_on_quit = 0;
      };
    };
  };
}
