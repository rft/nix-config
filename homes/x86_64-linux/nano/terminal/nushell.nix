{
  pkgs,
  lib,
  config,
  ...
}:
let
  terminalCfg = config.modules.home.terminal or { };
  nushellCfg = terminalCfg.nushell or { };
  envAssignments =
    lib.mapAttrsToList
      (name: value: ''$env.${name} = ${builtins.toJSON value}'')
      (nushellCfg.extraEnv or { });
  envSnippet =
    if envAssignments == [ ] then ""
    else
      lib.concatStringsSep "\n" envAssignments
      + "\n";
in
{
  options.modules.home.terminal.nushell.extraEnv = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = ''
      Environment variables to inject into Nushell via ``env.nu`` for the home
      terminal module.
    '';
  };

  config = lib.mkIf terminalCfg.enable {
    programs = {
      carapace.enable = true;

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      nushell = {
        enable = true;
        #plugins = with pkgs.nushellPlugins; [
        #  query
        #  polars
        #  units
        #  highlight
        #  skim
        #];
        extraConfig =
          ''
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
            $env.PATH = ($env.PATH |
            split row (char esep) |
            prepend /home/myuser/.apps |
            append /usr/bin/env
            )
          ''
          + lib.optionalString (envSnippet != "") ''
            # Environment variables provided via modules.home.terminal.nushell.extraEnv
            ${envSnippet}
          '';
      };

      yazi.enableNushellIntegration = true;
      thefuck.enableNushellIntegration = true;
      starship.enableNushellIntegration = true;
      broot.enableNushellIntegration = true;
      eza.enableNushellIntegration = true;
      carapace.enableNushellIntegration = true;

    };
  };
}
