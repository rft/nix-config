import datetime

start = datetime.datetime.now()

# The SQLite history backend saves command immediately
# unlike JSON backend that save the commands at the end of the session.
# https://xon.sh/envvars.html#histcontrol
$XONSH_HISTORY_FILE = $XDG_DATA_HOME + "/xonsh/history.sqlite"
$XONSH_HISTORY_BACKEND = "sqlite"
$HISTCONTROL = "erasedups"

$XONSH_SHOW_TRACEBACK = True

$AUTO_PUSHD = True

$MOUSE_SUPPORT = True

xontrib load \
    prompt_starship \
    sh \

# import rich.traceback
# rich.traceback.install()

print(f"+{(datetime.datetime.now() - start).total_seconds():.2f} xontrib load")

$fzf_file_binding = "c-t" # Ctrl+T


print(f"+{(datetime.datetime.now() - start).total_seconds():.2f} rc.xsh finished")
