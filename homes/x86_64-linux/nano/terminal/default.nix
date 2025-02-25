{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./starship.nix ./xonsh.nix ./kitty];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.nushell = {
    enable = true;
    #plugins = with pkgs.nushellPlugins; [
    #  query
    #  polars
    #  units
    #  highlight
    #  skim
    #];
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
       $env.PATH = ($env.PATH |
       split row (char esep) |
       prepend /home/myuser/.apps |
       append /usr/bin/env
       )
       '';
  };

  programs.zoxide.enableNushellIntegration.enable = true;
  programs.yazi.enableNushellIntegration.enable = true;
  programs.thefuck.enableNushellIntegration = true;
  programs.starship.enableNushellIntegration = true;
  programs.broot.enableNushellIntegration = true;
  programs.eza.enableNushellIntegration = true;
  programs.carapace.enableNushellIntegration = true;

}
