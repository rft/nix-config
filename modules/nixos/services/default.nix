{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services;
in
{
  options = {
    modules.services.enable = lib.mkEnableOption "services module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      borgmatic
      home-assistant
      jellyfin
      kasmweb
      n8n
      ollama
      paperless-ng
    ];
  };

}
