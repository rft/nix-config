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
        xonsh.xontribs.xontrib-vox
        xonsh.xontribs.xonsh-direnv
        # xonsh.xontribs.xontrib-mpl
        # xonsh.xontribs.xontrib-zoxide
        #xonsh.xontribs.xontrib-prompt-starship
      ];

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
