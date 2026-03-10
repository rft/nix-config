{ delib, ... }:
delib.module {
  name = "services";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = { pkgs, ... }: {
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
