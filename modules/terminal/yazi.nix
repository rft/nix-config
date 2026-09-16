{ delib, ... }:
let
  # omp's built-in "titanium" theme — same values as nixcat-nvim's
  # lua/core/palette.lua, so yazi, nvim and omp read as one scheme.
  t = {
    brushedTitanium = "#151820"; # background
    darkTitanium = "#0f1216"; # floats, bars
    electricBlue = "#00b4ff"; # accent
    deepBlue = "#0082b3";
    titaniumGold = "#d4c090";
    brightAluminum = "#e8ecf4"; # foreground
    dimAluminum = "#9ca3b0";
    warningAmber = "#ffb347";
    readoutGreen = "#00ff88";
    alertRed = "#ff4757";
    subtleGray = "#2a3038"; # borders, selection
    borderMuted = "#1f252d"; # cursorline
    comment = "#6b7280";
  };

  border = { fg = t.subtleGray; };
  accentBorder = { fg = t.electricBlue; };
  main = color: { fg = t.darkTitanium; bg = color; bold = true; };
  alt = color: { fg = color; bg = t.subtleGray; };
in
delib.module {
  name = "terminal.yazi";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.yazi = {
      enable = true;
      package = null; # installed system-wide in core
      shellWrapperName = "y";

      theme = {
        app.overall = { fg = t.brightAluminum; bg = t.brushedTitanium; };

        mgr = {
          cwd = { fg = t.electricBlue; };

          find_keyword = { fg = t.warningAmber; bold = true; underline = true; };
          find_position = { fg = t.titaniumGold; bold = true; italic = true; };

          symlink_target = { fg = t.dimAluminum; italic = true; };

          marker_copied = { fg = t.readoutGreen; bg = t.readoutGreen; };
          marker_cut = { fg = t.alertRed; bg = t.alertRed; };
          marker_marked = { fg = t.electricBlue; bg = t.electricBlue; };
          marker_selected = { fg = t.titaniumGold; bg = t.titaniumGold; };

          count_copied = main t.readoutGreen;
          count_cut = main t.alertRed;
          count_selected = main t.titaniumGold;

          border_symbol = "│";
          border_style = border;
        };

        tabs = {
          active = main t.electricBlue;
          inactive = alt t.dimAluminum;
        };

        mode = {
          normal_main = main t.electricBlue;
          normal_alt = alt t.electricBlue;
          select_main = main t.titaniumGold;
          select_alt = alt t.titaniumGold;
          unset_main = main t.alertRed;
          unset_alt = alt t.alertRed;
        };

        indicator = {
          parent = { fg = t.dimAluminum; bg = t.borderMuted; };
          current = { fg = t.brightAluminum; bg = t.subtleGray; bold = true; };
          preview = { bg = t.borderMuted; };
        };

        status = {
          overall = { fg = t.dimAluminum; bg = t.darkTitanium; };

          perm_sep = { fg = t.comment; };
          perm_type = { fg = t.electricBlue; };
          perm_read = { fg = t.titaniumGold; };
          perm_write = { fg = t.alertRed; };
          perm_exec = { fg = t.readoutGreen; };

          progress_label = { fg = t.brightAluminum; bold = true; };
          progress_normal = { fg = t.electricBlue; bg = t.subtleGray; };
          progress_error = { fg = t.alertRed; bg = t.subtleGray; };
        };

        which = {
          mask = { bg = t.darkTitanium; };
          cand = { fg = t.electricBlue; };
          rest = { fg = t.comment; };
          desc = { fg = t.dimAluminum; };
          separator_style = { fg = t.comment; };
        };

        confirm = {
          border = accentBorder;
          title = { fg = t.electricBlue; bold = true; };
          btn_yes = main t.electricBlue;
          btn_no = { fg = t.dimAluminum; };
        };

        spot = {
          border = accentBorder;
          title = { fg = t.electricBlue; bold = true; };
          tbl_col = { fg = t.electricBlue; };
          tbl_cell = { fg = t.brightAluminum; bg = t.subtleGray; };
        };

        notify = {
          title_info = { fg = t.readoutGreen; };
          title_warn = { fg = t.warningAmber; };
          title_error = { fg = t.alertRed; };
        };

        pick = {
          border = accentBorder;
          active = { fg = t.electricBlue; bold = true; };
        };

        input = {
          border = accentBorder;
          title = { fg = t.electricBlue; };
          selected = { bg = t.subtleGray; };
        };

        cmp = {
          border = accentBorder;
          active = { fg = t.brightAluminum; bg = t.subtleGray; bold = true; };
          inactive = { fg = t.dimAluminum; };
        };

        tasks = {
          border = accentBorder;
          title = { fg = t.electricBlue; };
          hovered = { fg = t.electricBlue; bold = true; };
        };

        help = {
          on = { fg = t.electricBlue; };
          run = { fg = t.readoutGreen; };
          desc = { fg = t.dimAluminum; };
          hovered = { bg = t.subtleGray; bold = true; };
          footer = { fg = t.brightAluminum; bg = t.subtleGray; };
        };

        filetype.rules = [
          { mime = "image/*"; fg = t.titaniumGold; }
          { mime = "{audio,video}/*"; fg = t.deepBlue; }
          { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = t.warningAmber; }
          { mime = "application/{pdf,doc,rtf}"; fg = t.dimAluminum; }
          { mime = "vfs/{absent,stale}"; fg = t.comment; }
          { url = "*"; is = "orphan"; fg = t.alertRed; }
          { url = "*"; is = "exec"; fg = t.readoutGreen; }
          { url = "*"; is = "dummy"; fg = t.alertRed; }
          { url = "*/"; is = "dummy"; fg = t.alertRed; }
          { url = "*/"; fg = t.electricBlue; bold = true; }
          { url = "*"; fg = t.brightAluminum; }
        ];
      };
    };
  };
}
