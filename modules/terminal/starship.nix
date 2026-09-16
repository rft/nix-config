{ delib, lib, ... }:
let
  t = import ../../lib/titanium-palette.nix;
in
delib.module {
  name = "terminal.starship";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.starship = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;

        # scan_timeout = 50
        # command_timeout = 1000
        # add_newline = false

        settings = {
          format = lib.concatStrings [
            "[╭─](bg1)"
            "[](bg0)"
            "[ 🌸 ](bg:bg0)"
            "$username"
            "[@](bg:bg0 fg:fg)"
            "$hostname"
            "$os"
            "$shell"
            "[](bg:bg1 fg:bg0)"
            "$directory"
            "[](bg:bg2 fg:bg1)"
            "$git_branch"
            "$git_status"
            "$git_metrics"
            "[](bg:bg3 fg:bg2)"
            "[](fg:bg3)"
            "$fill"
            "[](bg0)"
            "[$status](bg:bg0 fg:fg)"
            "$c"
            "$elixir"
            "$elm"
            "$golang"
            "$python"
            "$gradle"
            "$haskell"
            "$java"
            "$julia"
            "$nodejs"
            "$nim"
            "$rust"
            "$scala"
            "[](bg:bg0 fg:bg2)"
            "$cmd_duration"
            "[](bg:bg2 fg:bg1)"
            "$time"
            "[](fg:bg1)"
            "$line_break"
            "[╰─](bg1)"
            "$character"

          ];
          add_newline = true;
          palette = "titanium";

          # Segment backgrounds: bg1..bg3 step up in lightness; bg0 (the first
          # level) reuses the lightest so it stays visible on a black terminal.
          palettes.titanium = {
            bg0 = t.slate; # lightest step, so the first level stands out on black
            bg1 = t.borderMuted;
            bg2 = t.subtleGray;
            bg3 = t.slate;
            fg = t.brightAluminum;
            accent = t.electricBlue;
            gold = t.titaniumGold;
            red = t.alertRed;
            yellow = t.warningAmber;
            green = t.readoutGreen;
          };

          username = {
            style_root = "bg:bg0 fg:red";
            style_user = "bg:bg0 fg:fg";
            format = "[$user]($style)";
            show_always = true;
            disabled = false;
          };

          hostname = {
            ssh_only = false;
            ssh_symbol = " ";
            trim_at = ".";
            format = "[$hostname$ssh_symbol]($style)";
            style = "bg:bg0 fg:fg";
            disabled = false;
          };

          shell = {
            disabled = false;
            style = "bg:bg0 fg:fg";
            format = "[  $indicator]($style)";
          };
          os = {
            format = "[ $symbol ]($style)";
            style = "bg:bg0 fg:fg";
            disabled = true;
          };

          directory = {
            truncation_length = 3;
            truncate_to_repo = true;
            format = "[ $path ]($style)[$read_only]($read_only_style)";
            style = "bg:bg1 fg:accent";
            disabled = false;
            read_only = " 󰌾 ";
            read_only_style = "bg:bg1 fg:red";
            truncation_symbol = "";
            substitutions = {
              "Documents" = "󰈙";
              "Downloads" = " ";
              "Music" = " ";
              "Pictures" = " ";
              "Projects" = " ";
            };
          };

          fill = {
            disabled = false;
            symbol = "·";
          };

          time = {
            disabled = false;
            style = "bg:bg1 fg:fg";
            format = "[ $time ]($style)";
          };

          cmd_duration = {
            disabled = false;
            min_time = 0;
            min_time_to_notify = 6000;
            show_notifications = true;
            style = "bg:bg2 fg:fg";
            format = "[took $duration]($style)";
          };

          git_branch = {
            symbol = "";
            style = "bg:bg2 fg:gold";
            format = "[ $symbol $branch ]($style)";
          };

          git_status = {
            style = "bg:bg2 fg:fg";
            format = "[$all_status$ahead_behind ]($style)";
          };

          git_metrics = {
            added_style = "bg:bg2 fg:green";
            deleted_style = "bg:bg2 fg:red";
            format = "[+$added ]($added_style)[-$deleted ]($deleted_style)";
            disabled = false;
          };

          c = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };
          elixir = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          elm = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          golang = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          python = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) (\($virtualenv\)) ]($style)";
          };

          gradle = {
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          haskell = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          java = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          julia = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          nim = {
            symbol = "󰆥 ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          scala = {
            symbol = " ";
            style = "bg:bg0 fg:fg";
            format = "[ $symbol ($version) ]($style)";
          };

          status = {
            format = "[ $symbol ]($style)";
            style = "bg:bg0 fg:fg";
            symbol = "[](fg:green bg:bg0)";
            success_symbol = "[](fg:green bg:bg0)";
            not_executable_symbol = "[🛇](fg:red)";
            not_found_symbol = "[󰍉](fg:red)";
            sigint_symbol = "[](fg:yellow)";
            signal_symbol = "[](fg:red)";
            disabled = false;
          };

          os = {
            symbols = {
              Alpaquita = " ";
              Alpine = " ";
              Amazon = " ";
              Android = " ";
              Arch = " ";
              Artix = " ";
              CentOS = " ";
              Debian = " ";
              DragonFly = " ";
              Emscripten = " ";
              EndeavourOS = " ";
              Fedora = " ";
              FreeBSD = " ";
              Garuda = "󰛓 ";
              Gentoo = " ";
              HardenedBSD = "󰞌 ";
              Illumos = "󰈸 ";
              Linux = " ";
              Mabox = " ";
              Macos = " ";
              Manjaro = " ";
              Mariner = " ";
              MidnightBSD = " ";
              Mint = " ";
              NetBSD = " ";
              NixOS = " ";
              OpenBSD = "󰈺 ";
              openSUSE = " ";
              OracleLinux = "󰌷 ";
              Pop = " ";
              Raspbian = " ";
              Redhat = " ";
              RedHatEnterprise = " ";
              Redox = "󰀘 ";
              Solus = "󰠳 ";
              SUSE = " ";
              Ubuntu = " ";
              Unknown = " ";
              Windows = "󰍲 ";
            };
          };

        };
      };
  };
}
