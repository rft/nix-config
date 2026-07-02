{ delib, lib, inputs, pkgs, ... }:
delib.module {
  name = "desktop";

  options = delib.singleEnableOption false;

  home.always.imports = [ inputs.noctalia.homeModules.default ];

  # Baseline for all NixOS desktop hosts; everything uses mkDefault so hosts
  # can override individual values (e.g. sequoia/myrtle set a different timezone).
  nixos.ifEnabled = {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    networking.networkmanager.enable = lib.mkDefault true;
    time.timeZone = lib.mkDefault "America/Los_Angeles";

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: lib.mkDefault "en_US.UTF-8");

    services.xserver = {
      enable = lib.mkDefault true;
      xkb = {
        layout = lib.mkDefault "us";
        variant = lib.mkDefault "";
      };
    };
    services.printing.enable = lib.mkDefault true;

    services.pulseaudio.enable = lib.mkDefault false;
    security.rtkit.enable = lib.mkDefault true;
    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };

    programs.firefox.enable = lib.mkDefault true;
  };

  home.ifEnabled = {
    programs.noctalia = {
      enable = true;
      settings.theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Nord";
      };
    };
  };
}
