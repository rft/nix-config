{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.applications;
in
{
  options = {
    modules.applications.archiving.enable =
      lib.mkEnableOption "archiving tools for the applications module";
  };

  config = lib.mkIf (cfg.enable && cfg.archiving.enable) {
    environment.systemPackages = with pkgs; [
      archivebox
      galllery-dl
      hydrus
    ];
  };
}
