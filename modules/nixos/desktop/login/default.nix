{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = let
          startNiri = pkgs.writeShellScript "start-niri-session" ''
            #!${pkgs.runtimeShell}
            set -eu

            export XDG_SESSION_TYPE=wayland
            export XDG_CURRENT_DESKTOP=niri
            export XDG_SESSION_DESKTOP=niri
            export QT_QPA_PLATFORM=wayland
            export SDL_VIDEODRIVER=wayland
            export MOZ_ENABLE_WAYLAND=1

            exec ${pkgs.niri}/bin/niri-session
          '';
        in {
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${startNiri}";
          user = "greeter";
        };
      };
    };
  };
}
