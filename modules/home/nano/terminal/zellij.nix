{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.home.terminal.enable {
    programs.zellij.enable = true;

    # Use the built-in Nord theme provided by Zellij.
    xdg.configFile."zellij/config.kdl".text = ''
      theme "nord"
    '';
  };
}
