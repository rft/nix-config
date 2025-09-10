{ config, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd caelestia-shell";
        user = "greeter";
      };
    };
  };
}
