{ delib, lib, ... }:
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
            "[╭─](nord1)"
            "[](nord0)"
            "[ 🌸 ](bg:nord0)"
            "$username"
            "[@](bg:nord0 fg:nord4)"
            "$hostname"
            "$os"
            "$shell"
            "[](bg:nord1 fg:nord0)"
            "$directory"
            "[](bg:nord2 fg:nord1)"
            "$git_branch"
            "$git_status"
            "$git_metrics"
            "[](bg:nord3 fg:nord2)"
            "[](fg:nord3)"
            "$fill"
            "[](nord0)"
            "[$status](bg:nord0 fg:nord4)"
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
            "[](bg:nord0 fg:nord2)"
            "$cmd_duration"
            "[](bg:nord2 fg:nord1)"
            "$time"
            "[](fg:nord1)"
            "$line_break"
            "[╰─](nord1)"
            "$character"

          ];
          add_newline = true;
          palette = "nord";

          palettes = {
            nord = {
              nord0 = "#2E3440";
              nord1 = "#3B4252";
              nord2 = "#434C5E";
              nord3 = "#4C566A";
              nord4 = "#D8DEE9";
              nord11 = "#BF616A";
              nord13 = "#EBCB8B";
              nord14 = "#A2BE8A";
            };
          };

          username = {
            style_root = "bg:nord0 fg:nord11";
            style_user = "bg:nord0 fg:nord4";
            format = "[$user]($style)";
            show_always = true;
            disabled = false;
          };

          hostname = {
            ssh_only = false;
            ssh_symbol = " ";
            trim_at = ".";
            format = "[$hostname$ssh_symbol]($style)";
            style = "bg:nord0 fg:nord4";
            disabled = false;
          };

          shell = {
            disabled = false;
            style = "bg:nord0 fg:nord4";
            format = "[  $indicator]($style)";
          };
          os = {
            format = "[ $symbol ]($style)";
            style = "bg:nord0 fg:nord4";
            disabled = true;
          };

          directory = {
            truncation_length = 3;
            truncate_to_repo = true;
            format = "[ $path ]($style)[$read_only]($read_only_style)";
            style = "bg:nord1 fg:nord4";
            disabled = false;
            read_only = " 󰌾 ";
            read_only_style = "bg:nord1 fg:nord11";
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
            style = "bg:nord1 fg:nord4";
            format = "[ $time ]($style)";
          };

          cmd_duration = {
            disabled = false;
            min_time = 0;
            min_time_to_notify = 6000;
            show_notifications = true;
            style = "bg:nord2 fg:nord4";
            format = "[took $duration]($style)";
          };

          git_branch = {
            symbol = "";
            style = "bg:nord2 fg:nord4";
            format = "[ $symbol $branch ]($style)";
          };

          git_status = {
            style = "bg:nord2 fg:nord4";
            format = "[$all_status$ahead_behind ]($style)";
          };

          git_metrics = {
            added_style = "bg:nord2 fg:nord14";
            deleted_style = "bg:nord2 fg:nord11";
            format = "[+$added ]($added_style)[-$deleted ]($deleted_style)";
            disabled = false;
          };

          c = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };
          elixir = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          elm = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          golang = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          python = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) (\($virtualenv\)) ]($style)";
          };

          gradle = {
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          haskell = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          java = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          julia = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          nim = {
            symbol = "󰆥 ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          scala = {
            symbol = " ";
            style = "bg:nord0 fg:nord4";
            format = "[ $symbol ($version) ]($style)";
          };

          status = {
            format = "[ $symbol ]($style)";
            style = "bg:nord0 fg:nord4";
            symbol = "[](fg:nord14 bg:nord0)";
            success_symbol = "[](fg:nord14 bg:nord0)";
            not_executable_symbol = "[🛇](fg:nord11)";
            not_found_symbol = "[󰍉](fg:nord11)";
            sigint_symbol = "[](fg:nord13)";
            signal_symbol = "[](fg:nord11)";
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
