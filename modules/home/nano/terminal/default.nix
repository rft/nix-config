{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    modules.home.terminal.enable = lib.mkEnableOption "home terminal module";
  };

  imports = [
    ./starship.nix
    ./xonsh.nix
    ./kitty
    ./zellij.nix
    ./nushell.nix
  ];

  config = lib.mkIf config.modules.home.terminal.enable {
    # Probably should move this to it's own, but it's kind of small so idk
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
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
      #enableXonshIntegration = true;
      enableBashIntegration = true;
    };

  };
}
