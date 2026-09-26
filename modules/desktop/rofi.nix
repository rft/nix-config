{ delib, inputs, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  # Vertical layout (originally newmanls' Nord theme) recoloured with the
  # titanium palette shared with nvim, yazi, zellij and noctalia.
  theme = pkgs.writeText "titanium.rasi" ''
    configuration {
        show-icons: true;
    }

    * {
        font: "IBM Plex Mono 12";

        background-color: transparent;
        text-color:       ${t.brightAluminum};
        accent-color:     ${t.electricBlue};

        margin:  0px;
        padding: 0px;
        spacing: 0px;
    }

    window {
        background-color: ${t.brushedTitanium};
        border-color:     @accent-color;

        location: center;
        width:    480px;
        border:   1px;
    }

    inputbar {
        padding:  8px 12px;
        spacing:  12px;
        children: [ prompt, entry ];
        background-color: ${t.darkTitanium};
    }

    prompt, entry, element-text, element-icon {
        vertical-align: 0.5;
    }

    prompt {
        text-color: @accent-color;
    }

    entry {
        placeholder-color: ${t.comment};
    }

    listview {
        lines:   8;
        columns: 1;

        fixed-height:     false;
        spacing:          1px;
        background-color: ${t.subtleGray};
    }

    element {
        padding: 8px;
        spacing: 8px;
        background-color: ${t.brushedTitanium};
    }

    element alternate normal {
        background-color: ${t.borderMuted};
    }

    element normal urgent, element alternate urgent {
        text-color: ${t.warningAmber};
    }

    element normal active, element alternate active {
        text-color: @accent-color;
    }

    element selected {
        text-color: ${t.darkTitanium};
    }

    element selected normal {
        background-color: @accent-color;
    }

    element selected urgent {
        background-color: ${t.warningAmber};
    }

    element selected active {
        background-color: ${t.deepBlue};
    }

    element-icon {
        size: 0.75em;
    }

    element-text {
        text-color: inherit;
    }
  '';
in
delib.module {
  name = "desktop.rofi";

  options = delib.singleEnableOption false;

  myconfig.always = { myconfig, ... }: {
    desktop.rofi.enable = lib.mkDefault (myconfig.desktop.enable or false);
  };

  home.ifEnabled = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      theme = "${theme}";
    };

    home.packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rofi-desktop
      pkgs.libdbusmenu
    ];

    systemd.user.services.rofi-appmenu-service = {
      Unit = {
        Description = "AppMenu registrar for rofi-desktop HUD";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rofi-desktop}/bin/rofi-appmenu-service";
        Restart = "on-failure";
        RestartSec = 2;
        Environment = "PYTHONUNBUFFERED=1";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
