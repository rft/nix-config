{ delib, lib, pkgs, ... }:
let
  t = import ../../lib/titanium-palette.nix;
  syntax = import ../../lib/titanium-syntax.nix;

  # fzf has no config file of its own; FZF_DEFAULT_OPTS_FILE points at this.
  # `-1` keeps the terminal background, so fzf sits flush with kitty.
  fzfColors = lib.concatStringsSep "," (
    lib.mapAttrsToList (k: v: "${k}:${v}") {
      fg = t.dimAluminum;
      bg = "-1";
      "fg+" = t.brightAluminum;
      "bg+" = t.subtleGray;
      hl = t.electricBlue;
      "hl+" = t.electricBlue;
      query = t.brightAluminum;
      prompt = t.electricBlue;
      pointer = t.electricBlue;
      marker = t.readoutGreen;
      spinner = t.titaniumGold;
      info = t.titaniumGold;
      header = t.comment;
      border = t.subtleGray;
      separator = t.subtleGray;
      scrollbar = t.subtleGray;
      label = t.dimAluminum;
      gutter = "-1";
    }
  );

  # bat reads Sublime .tmTheme plists, built from the same scope rules as
  # vscodium's token colours.
  plistDict =
    attrs:
    "<dict>"
    + lib.concatStrings (
      lib.mapAttrsToList (
        k: v: "<key>${k}</key>" + (if lib.isAttrs v then plistDict v else "<string>${v}</string>")
      ) attrs
    )
    + "</dict>";

  batTheme = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
    <key>name</key><string>Titanium</string>
    <key>settings</key><array>
    ${plistDict {
      settings = {
        background = t.brushedTitanium;
        foreground = t.brightAluminum;
        caret = t.electricBlue;
        selection = t.subtleGray;
        lineHighlight = t.borderMuted;
        gutterForeground = t.comment;
      };
    }}
    ${lib.concatMapStrings (
      r:
      plistDict {
        scope = lib.concatStringsSep ", " r.scope;
        settings = {
          inherit (r) foreground;
        }
        // lib.optionalAttrs (r.fontStyle != null) { inherit (r) fontStyle; };
      }
    ) syntax}
    </array></dict></plist>
  '';
in
delib.module {
  name = "terminal.colors";

  options = delib.singleEnableOption true;

  # Titanium palette for the TUI tools that don't have a module of their own.
  # Packages stay in core; only config is managed here.
  home.ifEnabled = {
    xdg.configFile."fzf/fzfrc".text = "--color=${fzfColors}\n";
    # xonsh and nushell don't read home.sessionVariables; they set it themselves.
    home.sessionVariables.FZF_DEFAULT_OPTS_FILE = "$HOME/.config/fzf/fzfrc";

    programs.bat = {
      enable = true;
      themes.titanium = {
        src = pkgs.writeTextDir "titanium.tmTheme" batTheme;
        file = "titanium.tmTheme";
      };
      config.theme = "titanium";
    };

    programs.lazygit = {
      enable = true;
      package = null;
      settings.gui.theme = {
        activeBorderColor = [ t.electricBlue "bold" ];
        inactiveBorderColor = [ t.subtleGray ];
        searchingActiveBorderColor = [ t.warningAmber "bold" ];
        optionsTextColor = [ t.electricBlue ];
        selectedLineBgColor = [ t.subtleGray ];
        inactiveViewSelectedLineBgColor = [ t.borderMuted ];
        cherryPickedCommitFgColor = [ t.electricBlue ];
        cherryPickedCommitBgColor = [ t.subtleGray ];
        markedBaseCommitFgColor = [ t.titaniumGold ];
        markedBaseCommitBgColor = [ t.subtleGray ];
        unstagedChangesColor = [ t.alertRed ];
        defaultFgColor = [ t.brightAluminum ];
      };
    };

    # Managing settings makes config.toml read-only, so the options set by
    # hand there before (enter_accept, sync.records) are carried over.
    programs.atuin = {
      forceOverwriteSettings = true;
      settings = {
        enter_accept = true;
        sync.records = true;
        theme.name = "titanium";
      };
      themes.titanium = {
        theme.name = "titanium";
        colors = {
          Base = t.brightAluminum;
          Title = t.electricBlue;
          Guidance = t.dimAluminum;
          Annotation = t.comment;
          Muted = t.comment;
          Important = t.titaniumGold;
          AlertInfo = t.readoutGreen;
          AlertWarn = t.warningAmber;
          AlertError = t.alertRed;
        };
      };
    };

    programs.bottom = {
      enable = true;
      package = null;
      settings.styles = {
        cpu = {
          all_entry_color = t.electricBlue;
          avg_entry_color = t.titaniumGold;
          cpu_core_colors = [
            t.electricBlue
            t.readoutGreen
            t.titaniumGold
            t.warningAmber
            t.deepBlue
            t.alertRed
            t.dimAluminum
          ];
        };
        temp_graph.temp_graph_color_styles = [
          t.electricBlue
          t.readoutGreen
          t.titaniumGold
          t.warningAmber
          t.alertRed
        ];
        memory = {
          ram_color = t.electricBlue;
          cache_color = t.titaniumGold;
          swap_color = t.warningAmber;
          arc_color = t.readoutGreen;
          gpu_colors = [ t.readoutGreen t.deepBlue t.alertRed ];
        };
        network = {
          rx_color = t.readoutGreen;
          tx_color = t.electricBlue;
          rx_total_color = t.readoutGreen;
          tx_total_color = t.electricBlue;
        };
        battery = {
          high_battery_color = t.readoutGreen;
          medium_battery_color = t.warningAmber;
          low_battery_color = t.alertRed;
        };
        tables.headers = {
          color = t.electricBlue;
          bold = true;
        };
        graphs = {
          graph_color = t.subtleGray;
          legend_text.color = t.dimAluminum;
        };
        widgets = {
          border_color = t.subtleGray;
          selected_border_color = t.electricBlue;
          widget_title.color = t.titaniumGold;
          text.color = t.brightAluminum;
          selected_text = {
            color = t.darkTitanium;
            bg_color = t.electricBlue;
          };
          disabled_text.color = t.comment;
          thread_text.color = t.readoutGreen;
        };
      };
    };
  };
}
