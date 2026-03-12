{ delib, ... }:
delib.module {
  name = "terminal.nushell";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs = {
      carapace.enable = true;

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      nushell = {
        enable = true;
        extraConfig = ''
          let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
          }
          $env.config = {
           show_banner: false,
           completions: {
           case_sensitive: false # case-sensitive completions
           quick: true    # set to false to prevent auto-selecting completions
           partial: true    # set to false to prevent partial filling of the prompt
           algorithm: "fuzzy"    # prefix or fuzzy
           external: {
           # set to false to prevent nushell looking into $env.PATH to find more suggestions
               enable: true
           # set to lower can improve completion performance at the cost of omitting some options
               max_results: 100
               completer: $carapace_completer # check 'carapace_completer'
             }
           }
          }
          if (($env.TERM? | default "" | str starts-with "xterm-kitty")) {
            alias rg = rg --hyperlink-format=kitty
          }
          $env.PATH = ($env.PATH |
          split row (char esep) |
          prepend /home/myuser/.apps |
          append /usr/bin/env
          )
        '';
      };

      yazi.enableNushellIntegration = true;
      starship.enableNushellIntegration = true;
      broot.enableNushellIntegration = true;
      eza.enableNushellIntegration = true;
      carapace.enableNushellIntegration = true;
    };
  };
}
