{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  xonshExtraPackages = import ../../../../lib/xonsh-extra-packages.nix;
  xxh = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.xxh;
in
{
  config = lib.mkIf config.modules.home.terminal.enable {
    home.packages = [
      pkgs.starship
      xxh
      (pkgs.python3.withPackages (ps: [ ps.xonsh ] ++ xonshExtraPackages ps))
    ];

    programs.fzf.enable = true;

    home.file.".config/xonsh/rc.xsh".text = ''
      $XONSH_SHOW_TRACEBACK = True
      if $KITTY_WINDOW_ID:
          aliases['rg'] = 'rg --hyperlink-format=kitty'

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
      # This screws up copy and pasting for WSL though so I'm not sure what the ideal fix is
      [$PATH.remove(path) for path in $PATH.paths if path.startswith("/mnt/c/")]
      # Allow a minimal set of Windows executables.
      # Use WIN_USER override when Windows username differs from WSL username.
      import os
      win_user = __xonsh__.env.get("WIN_USER")
      if not win_user:
          wsl_user = __xonsh__.env.get("USER")
          if wsl_user and os.path.isdir(f"/mnt/c/Users/{wsl_user}"):
              win_user = wsl_user
          else:
              users_root = "/mnt/c/Users"
              if os.path.isdir(users_root):
                  candidates = [
                      d for d in os.listdir(users_root)
                      if d not in ("All Users", "Default", "Default User", "Public", "desktop.ini")
                  ]
                  win_user = candidates[0] if candidates else None
              else:
                  win_user = None
      if win_user:
          $PATH.append(f"/mnt/c/Users/{win_user}/AppData/Local/Programs/Microsoft VS Code/bin")
      $PATH.append("/mnt/c/Windows")
    '';
  };
}
