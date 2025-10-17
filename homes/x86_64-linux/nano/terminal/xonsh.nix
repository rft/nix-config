{ pkgs, config, lib, ... }:
{
  config = lib.mkIf config.modules.home.terminal.enable {
    home.packages = [
      pkgs.starship
    ];

    programs.fzf.enable = true;

    home.file.".config/xonsh/rc.xsh".text = ''
      $XONSH_SHOW_TRACEBACK = True

      try:
          execx($(atuin init xonsh))
      except Exception:
          pass

      try:
          execx($(starship init xonsh))
      except Exception:
          pass
    '';
  };
}
