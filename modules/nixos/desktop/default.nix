{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    modules.desktop.enable = lib.mkEnableOption "desktop module";
  };

  imports = [
    ./awesome
    ./login
    inputs.noctalia.nixosModules.default
  ];

  config = lib.mkIf config.modules.desktop.enable {
    services.noctalia-shell = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}
