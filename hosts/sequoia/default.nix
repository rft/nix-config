{ delib, pkgs, ... }:
let
  # vmware-user syncs the host clipboard with the X11 (Xwayland) clipboard only,
  # and xwayland-satellite only bridges X11 <-> Wayland while an X11 window has
  # focus. Bridge the two clipboards directly so copy/paste with the host works.
  clipboardBridge = pkgs.writeShellApplication {
    name = "x11-wayland-clipboard-bridge";
    runtimeInputs = with pkgs; [ wl-clipboard xclip clipnotify coreutils ];
    text = ''
      # Wayland -> X11 (wl-paste --watch re-invokes this script per change)
      if [ "''${1:-}" = to-x11 ]; then
        new=$(cat)
        [ "$new" = "$(xclip -selection clipboard -o 2>/dev/null)" ] ||
          printf %s "$new" | xclip -selection clipboard -i
        exit 0
      fi
      wl-paste --type text --watch "$0" to-x11 &

      # X11 -> Wayland
      while clipnotify -s clipboard; do
        new=$(xclip -selection clipboard -o 2>/dev/null) || continue
        [ "$new" = "$(wl-paste --no-newline 2>/dev/null)" ] ||
          printf %s "$new" | wl-copy
      done
    '';
  };
in
delib.host {
  name = "sequoia";
  type = "desktop";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  home.systemd.user.services.x11-wayland-clipboard-bridge = {
    Unit = {
      Description = "Sync X11 and Wayland clipboards (VMware copy/paste)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [ "DISPLAY=:0" ];
      ExecStart = "${clipboardBridge}/bin/x11-wayland-clipboard-bridge";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

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
