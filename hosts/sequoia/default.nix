{ delib, ... }:
delib.host {
  name = "sequoia";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = {
    system.stateVersion = "24.11";
    imports = [ ../../hardware/sequoia.nix ];

    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };

    virtualisation.vmware.guest.enable = true;

    time.timeZone = "America/Phoenix";

    # Running under VMware: the emulated HD-Audio driver returns bad timing info
    # (snd_pcm_avail "Broken pipe"), so PipeWire's default timer-based scheduling
    # underruns and stutters during video playback (146 xruns/15s observed).
    # Switching the ALSA sink to IRQ/period-based scheduling fixes it (xruns -> 0).
    services.pipewire.wireplumber.extraConfig."99-vm-alsa-irq" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_output.*"; } ];
          actions.update-props = {
            "api.alsa.disable-tsched" = true;
            "api.alsa.headroom" = 4096;
            "api.alsa.period-size" = 1024;
          };
        }
      ];
    };
  };

  myconfig = {
    applications.enable = true;
    applications.creative.enable = true;
    applications.engineering.enable = true;
    desktop.enable = true;
    programs.programming.enable = true;
  };
}
