{ delib, lib, inputs, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;
in
delib.module {
  name = "desktop";

  options = delib.singleEnableOption false;

  home.always.imports = [ inputs.noctalia.homeModules.default ];

  # Baseline for all NixOS desktop hosts; everything uses mkDefault so hosts
  # can override individual values (e.g. sequoia/myrtle set a different timezone).
  nixos.ifEnabled = {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.netbird-ui
    ];

    # Espanso's NixOS module adds the cap_dac_override wrapper that the
    # wayland build needs and starts the daemon with graphical-session.target.
    services.espanso = {
      enable = true;
      package = pkgs.espanso-wayland;
    };

    # Tray apps launched with the session (the netbird daemon itself runs
    # system-wide from modules/core).
    systemd.user.services = lib.mapAttrs (name: cmd: {
      description = "${name} tray app";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = cmd;
        Restart = "on-failure";
      };
    }) {
      handy = "${lib.getExe pkgs.handy} --start-hidden";
      netbird-ui = lib.getExe pkgs.netbird-ui;
    };

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

  home.ifEnabled = { myconfig, ... }: {
    # Symlinked into the repo (like niri) so matches stay editable without a
    # rebuild; match/packages stays in ~/.config for `espanso install`.
    home.file = let
      repo = "/home/${myconfig.constants.username}/nix-config/config/espanso";
      link = name: path: pkgs.runCommandLocal "espanso-${name}-symlink" {} "ln -s ${repo}/${path} $out";
    in {
      ".config/espanso/config".source = link "config" "config";
      ".config/espanso/match/base.yml".source = link "base" "match/base.yml";
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings.theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "Titanium";
      };
      # Same palette as nvim, yazi, zellij and omp. No light variant, so
      # noctalia reuses the dark one in light mode.
      customPalettes.Titanium.dark = with t; {
        mPrimary = electricBlue;
        mOnPrimary = darkTitanium;
        mSecondary = titaniumGold;
        mOnSecondary = darkTitanium;
        mTertiary = readoutGreen;
        mOnTertiary = darkTitanium;
        mError = alertRed;
        mOnError = darkTitanium;
        mSurface = brushedTitanium;
        mOnSurface = brightAluminum;
        mSurfaceVariant = borderMuted;
        mOnSurfaceVariant = dimAluminum;
        mOutline = subtleGray;
        mShadow = darkTitanium;
        mHover = subtleGray;
        mOnHover = brightAluminum;
        terminal = {
          background = brushedTitanium;
          foreground = brightAluminum;
          cursor = electricBlue;
          cursorText = darkTitanium;
          selectionBg = subtleGray;
          selectionFg = brightAluminum;
          normal = {
            black = subtleGray;
            red = alertRed;
            green = readoutGreen;
            yellow = warningAmber;
            blue = deepBlue;
            magenta = titaniumGold;
            cyan = electricBlue;
            white = dimAluminum;
          };
          bright = {
            black = comment;
            red = alertRed;
            green = readoutGreen;
            yellow = warningAmber;
            blue = electricBlue;
            magenta = titaniumGold;
            cyan = electricBlue;
            white = brightAluminum;
          };
        };
      };
    };
  };
}
