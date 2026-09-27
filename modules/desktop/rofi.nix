{ delib, inputs, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;

  # Single-column list (originally newmanls' windows11-list theme) recoloured
  # with the titanium palette shared with nvim, yazi, zellij and noctalia.
  theme = pkgs.writeText "titanium.rasi" ''
    configuration {
        show-icons: true;
    }

    * {
        font: "FiraCode Nerd Font 11";

        background-color: transparent;
        text-color:       ${t.brightAluminum};
        accent-color:     ${t.electricBlue};

        margin:  0px;
        padding: 0px;
        spacing: 0px;
    }

    element-icon, element-text, scrollbar {
        cursor: pointer;
    }

    window {
        location: center;
        width:    560px;

        background-color: ${t.brushedTitanium};
        border:           1px;
        border-color:     ${t.subtleGray};
        border-radius:    8px;
    }

    mainbox {
        padding: 16px;
        spacing: 16px;
    }

    inputbar {
        padding:  8px;
        spacing:  8px;
        children: [ textbox-search, entry ];

        background-color: ${t.darkTitanium};
        border:           0px 0px 2px 0px solid;
        border-color:     @accent-color;
        border-radius:    4px;
    }

    textbox-search, entry, element-icon, element-text {
        vertical-align: 0.5;
    }

    // Nerd Font magnifier glyph; the search-symbolic icon isn't in the icon theme.
    textbox-search {
        expand:     false;
        // Mono variant keeps the glyph inside its cell so it isn't clipped.
        font:       "FiraCode Nerd Font Mono 14";
        str:        "";
        text-color: @accent-color;
    }

    entry {
        font:              "FiraCode Nerd Font 12";
        placeholder:       "Type here to search";
        placeholder-color: ${t.comment};
    }

    textbox {
        padding:          4px 8px;
        background-color: ${t.darkTitanium};
    }

    listview {
        lines:        8;
        columns:      1;
        spacing:      4px;
        fixed-height: false;
        scrollbar:    false;
    }

    element {
        padding:       6px 8px;
        spacing:       12px;
        border-radius: 4px;
    }

    element normal urgent, element alternate urgent {
        text-color: ${t.warningAmber};
    }

    element normal active, element alternate active, element selected active {
        text-color: @accent-color;
    }

    element selected {
        background-color: ${t.subtleGray};
    }

    element selected urgent {
        background-color: ${t.warningAmber};
        text-color:       ${t.darkTitanium};
    }

    element-icon {
        size: 32px;
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
