{ delib, ... }:
delib.module {
  name = "terminal";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        if [[ "''${TERM-}" == xterm-kitty* ]]; then
          alias rg='rg --hyperlink-format=kitty'
        fi
        # mkcd: create a directory (and parents) then cd into it
        mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
      '';
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        if [[ "''${TERM-}" == xterm-kitty* ]]; then
          alias rg='rg --hyperlink-format=kitty'
        fi
        # mkcd: create a directory (and parents) then cd into it
        mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
      '';
    };

    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
