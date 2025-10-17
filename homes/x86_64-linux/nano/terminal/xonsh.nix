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

      try:
          execx($(zoxide init xonsh))
      except Exception:
          pass
      # Remove WSL paths from xonsh otherwise it's really slow, doesn't fix startup problems but it helps see https://github.com/xonsh/xonsh/issues/3895
      [$PATH.remove(path) for path in $PATH.paths if path.startswith("/mnt/c/")]
    '';
  };
}
