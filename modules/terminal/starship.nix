{ delib, lib, ... }:
delib.module {
  name = "terminal.starship";

  options = delib.singleEnableOption true;

  home.ifEnabled =
  let
    # BMP Private Use Area glyphs get stripped by LLM tooling when stored
    # as literal characters. Define them via JSON unicode escapes instead.
    u = code: builtins.fromJSON ''"\\u${code}"'';

    # Powerline arrows
    arrow-right = u "e0b0";
    arrow-left  = u "e0b2";

    # Nerd Font icons (exact codepoints from original config)
    ic-ssh      = u "eb01";
    ic-terminal = u "f489";
    ic-git      = u "f418";
    ic-c        = u "e61e";
    ic-elixir   = u "e275";
    ic-elm      = u "e62c";
    ic-go       = u "e627";
    ic-python   = u "e73c";
    ic-haskell  = u "e777";
    ic-java     = u "e256";
    ic-julia    = u "e624";
    ic-nodejs   = u "e718";
    ic-rust     = u "e7a8";
    ic-scala    = u "e737";
    ic-status   = u "f467";
    ic-success  = u "eab2";
    ic-signal   = u "e00a";

    # OS distro icons
    ic-alpaquita    = u "eaa2";
    ic-alpine       = u "f300";
    ic-amazon       = u "f270";
    ic-android      = u "f17b";
    ic-arch         = u "f303";
    ic-artix        = u "f31f";
    ic-centos       = u "f304";
    ic-debian       = u "f306";
    ic-dragonfly    = u "e28e";
    ic-emscripten   = u "f205";
    ic-endeavouros  = u "f197";
    ic-fedora       = u "f30a";
    ic-freebsd      = u "f30c";
    ic-gentoo       = u "f30d";
    ic-linux        = u "f31a";
    ic-mabox        = u "eb29";
    ic-macos        = u "f302";
    ic-manjaro      = u "f312";
    ic-mariner      = u "f1cd";
    ic-midnightbsd  = u "f186";
    ic-mint         = u "f30e";
    ic-netbsd       = u "f024";
    ic-nixos        = u "f313";
    ic-opensuse     = u "f314";
    ic-pop          = u "f32a";
    ic-raspbian     = u "f315";
    ic-redhat       = u "f316";
    ic-ubuntu       = u "f31b";
    ic-unknown      = u "f22d";

    # Directory substitution icons
    ic-download = u "f019";
    ic-music    = u "f001";
    ic-pictures = u "f03e";
    ic-projects = u "ebdf";
  in
  {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;

      settings = {
        format = lib.concatStrings [
          "[╭─](nord1)"
          "[${arrow-left}](nord0)"
          "[ 🌸 ](bg:nord0)"
          "$username"
          "[@](bg:nord0 fg:nord4)"
          "$hostname"
          "$os"
          "$shell"
          "[${arrow-right}](bg:nord1 fg:nord0)"
          "$directory"
          "[${arrow-right}](bg:nord2 fg:nord1)"
          "$git_branch"
          "$git_status"
          "$git_metrics"
          "[${arrow-right}](bg:nord3 fg:nord2)"
          "[${arrow-right}](fg:nord3)"
          "$fill"
          "[${arrow-left}](nord0)"
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
          "[${arrow-left}](bg:nord0 fg:nord2)"
          "$cmd_duration"
          "[${arrow-left}](bg:nord2 fg:nord1)"
          "$time"
          "[${arrow-right}](fg:nord1)"
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
          ssh_symbol = " ${ic-ssh}";
          trim_at = ".";
          format = "[$hostname$ssh_symbol]($style)";
          style = "bg:nord0 fg:nord4";
          disabled = false;
        };

        shell = {
          disabled = false;
          style = "bg:nord0 fg:nord4";
          format = "[ ${ic-terminal} $indicator]($style)";
        };

        os = {
          format = "[ $symbol ]($style)";
          style = "bg:nord0 fg:nord4";
          disabled = true;
          symbols = {
            Alpaquita = "${ic-alpaquita} ";
            Alpine = "${ic-alpine} ";
            Amazon = "${ic-amazon} ";
            Android = "${ic-android} ";
            Arch = "${ic-arch} ";
            Artix = "${ic-artix} ";
            CentOS = "${ic-centos} ";
            Debian = "${ic-debian} ";
            DragonFly = "${ic-dragonfly} ";
            Emscripten = "${ic-emscripten} ";
            EndeavourOS = "${ic-endeavouros} ";
            Fedora = "${ic-fedora} ";
            FreeBSD = "${ic-freebsd} ";
            Garuda = "󰛓 ";
            Gentoo = "${ic-gentoo} ";
            HardenedBSD = "󰞌 ";
            Illumos = "󰈸 ";
            Linux = "${ic-linux} ";
            Mabox = "${ic-mabox} ";
            Macos = "${ic-macos} ";
            Manjaro = "${ic-manjaro} ";
            Mariner = "${ic-mariner} ";
            MidnightBSD = "${ic-midnightbsd} ";
            Mint = "${ic-mint} ";
            NetBSD = "${ic-netbsd} ";
            NixOS = "${ic-nixos} ";
            OpenBSD = "󰈺 ";
            openSUSE = "${ic-opensuse} ";
            OracleLinux = "󰌷 ";
            Pop = "${ic-pop} ";
            Raspbian = "${ic-raspbian} ";
            Redhat = "${ic-redhat} ";
            RedHatEnterprise = "${ic-redhat} ";
            Redox = "󰀘 ";
            Solus = "󰠳 ";
            SUSE = "${ic-opensuse} ";
            Ubuntu = "${ic-ubuntu} ";
            Unknown = "${ic-unknown} ";
            Windows = "󰍲 ";
          };
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
            "Downloads" = "${ic-download} ";
            "Music" = "${ic-music} ";
            "Pictures" = "${ic-pictures} ";
            "Projects" = "${ic-projects} ";
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
          symbol = "${ic-git}";
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
          symbol = "${ic-c} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        elixir = {
          symbol = "${ic-elixir} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        elm = {
          symbol = "${ic-elm} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        golang = {
          symbol = "${ic-go} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        python = {
          symbol = "${ic-python} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) (\($virtualenv\)) ]($style)";
        };

        gradle = {
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        haskell = {
          symbol = "${ic-haskell} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        java = {
          symbol = "${ic-java} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        julia = {
          symbol = "${ic-julia} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        nodejs = {
          symbol = "${ic-nodejs}";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        nim = {
          symbol = "󰆥 ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        rust = {
          symbol = "${ic-rust}";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        scala = {
          symbol = "${ic-scala} ";
          style = "bg:nord0 fg:nord4";
          format = "[ $symbol ($version) ]($style)";
        };

        status = {
          format = "[ $symbol ]($style)";
          style = "bg:nord0 fg:nord4";
          symbol = "[${ic-status}](fg:nord14 bg:nord0)";
          success_symbol = "[${ic-success}](fg:nord14 bg:nord0)";
          not_executable_symbol = "[🛇](fg:nord11)";
          not_found_symbol = "[󰍉](fg:nord11)";
          sigint_symbol = "[${ic-signal}](fg:nord13)";
          signal_symbol = "[${ic-signal}](fg:nord11)";
          disabled = false;
        };
      };
    };
  };
}
