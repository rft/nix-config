{
  pkgs,
  config,
  inputs,
  ...
}:
{
  # environment.systemPackages = with pkgs; [
  #   xonsh
  #   nur.repos.xonsh-xontribs.xontrib-prompt-starship
  #   #nur.repos.xonsh-xontribs.xontrib-fish-completer
  #   #nur.repos.xonsh-xontribs.xonsh
  # ];

  programs.xonsh = {
    enable = true;
    extraPackages =
      ps: with ps; [
        numpy
        requests
        coconut
        sympy
        matplotlib
        scipy
        polars
        pandas
        beautifulsoup4
        ipdb
        xonsh.xontribs.xontrib-vox
        xonsh.xontribs.xonsh-direnv
        xonsh.xontribs.xontrib-whole-word-jumping
        xonsh.xontribs.xontrib-bashisms
        #xonsh.xontribs.xontrib-mpl
        #xonsh.xontribs.xontrib-prompt-starship
      ];

    # Looks like the only ones available right now are
    # nix repl github:NixOS/nixpkgs
    # nix repl github:nixos/nixpkgs/nixos-unstable
    # legacyPackages.x86_64-linux.xonsh.xontribs ->
    # {
    #   xonsh-direnv = «derivation /nix/store/ziwwgf6m3yskyxf62rqcbni8b8l4b8h8-python3.13-xonsh-direnv-1.6.5.drv»;
    #   xontrib-abbrevs = «derivation /nix/store/pa0wn219xp6c9f1b0axh3zisazpkrj4a-python3.13-xontrib-abbrevs-0.1.0.drv»;
    #   xontrib-bashisms = «derivation /nix/store/8vkwp2l06mmfsknf6b0bz2sxvkpkns0l-python3.13-xontrib-bashisms-0.0.5.drv»;
    #   xontrib-debug-tools = «derivation /nix/store/2l6n5kv2bjij9m36y8hx4qncfirl6bhq-python3.13-xontrib-debug-tools-0.0.1.drv»;
    #   xontrib-distributed = «derivation /nix/store/8xfv0msm8nxp48q84hsdzhhwai266qk3-python3.13-xontrib-distributed-0.0.4.drv»;
    #   xontrib-fish-completer = «derivation /nix/store/3p5cxjj2zyshmd84l84b4g4yjlp7yf6w-python3.13-xontrib-fish-completer-0.0.1.drv»;
    #   xontrib-jedi = «derivation /nix/store/a7b09jasfpv5l3gbvds3zilag3x2w7qi-python3.13-xontrib-jedi-0.1.1.drv»;
    #   xontrib-jupyter = «derivation /nix/store/i3g0a3hcfybrvh0bdg3fmkaiz01i7fwy-python3.13-xontrib-jupyter-0.3.2.drv»;
    #   xontrib-vox = «derivation /nix/store/2hzsciragljxlwijiwkbrpy91vf8gfyd-python3.13-xontrib-vox-0.0.1.drv»;
    #   xontrib-whole-word-jumping = «derivation /nix/store/9078p2bx8lsj7iy6i9i9j3i19va2ar7r-python3.13-xontrib-whole-word-jumping-0.0.1.drv»;
    # }

    # TODO: Add config
    # import datetime

    # start = datetime.datetime.now()

    # # The SQLite history backend saves command immediately
    # # unlike JSON backend that save the commands at the end of the session.
    # # https://xon.sh/envvars.html#histcontrol
    # $XONSH_HISTORY_FILE = $XDG_DATA_HOME + "/xonsh/history.sqlite"
    # $XONSH_HISTORY_BACKEND = "sqlite"
    # $HISTCONTROL = "erasedups"

    # $XONSH_SHOW_TRACEBACK = True

    # $AUTO_PUSHD = True

    # $MOUSE_SUPPORT = True

    # xontrib load \
    #     prompt_starship \
    #     sh \
    #     direnv

    # # import rich.traceback
    # # rich.traceback.install()

    # print(f"+{(datetime.datetime.now() - start).total_seconds():.2f} xontrib load")

    # $fzf_file_binding = "c-t" # Ctrl+T

    # print(f"+{(datetime.datetime.now() - start).total_seconds():.2f} rc.xsh finished")

  };

}
