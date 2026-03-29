{ delib, pkgs, ... }:
delib.module {
  name = "services";

  options = delib.singleEnableOption false;

  nixos.ifEnabled = {
    environment.systemPackages = with pkgs; [
      borgmatic
    ];

    # Jellyfin media server
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Ollama LLM inference
    services.ollama = {
      enable = true;
    };

    # Home Assistant
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "America/Phoenix";
        };
        default_config = {};
      };
    };

    # n8n workflow automation
    services.n8n = {
      enable = true;
      openFirewall = true;
    };

    # Paperless document management
    services.paperless = {
      enable = true;
    };
  };
}
