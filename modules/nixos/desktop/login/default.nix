{
  config,
  pkgs,
  inputs,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd caelestia-shell";
        user = "greeter";
      };
    };
  };
}
