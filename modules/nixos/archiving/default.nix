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
  config = lib.mkIf (cfg.enable && cfg.archiving.enable) {
    environment.systemPackages = with pkgs; [
      archivebox
      galllery-dl
      hydrus
    ];
  };
}
