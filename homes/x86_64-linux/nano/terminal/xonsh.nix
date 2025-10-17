{ pkgs, config, lib, ... }:
{
  config = lib.mkIf config.modules.home.terminal.enable {
    home.packages = [
      pkgs.starship
    ];

    programs.fzf.enable = true;

    home.file.".config/xonsh/rc.xsh".text = ''
      try:
          execx($(atuin init xonsh))
      except Exception:
          pass
    '';
  };
}
