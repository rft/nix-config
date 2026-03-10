{ delib, ... }:
delib.module {
  name = "terminal.zellij";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.zellij.enable = true;
    xdg.configFile."zellij/config.kdl".text = ''
      theme "nord"
    '';
  };
}
