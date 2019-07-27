#@IgnoreInspection BashAddShebang
# This script is meant for quick & easy install via:
#   $ curl -fsSL "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o - | sudo bash /dev/stdin install

# define colors that are used in the help screen
ESC_SEQ="\x1b["
COL_RESET=${ESC_SEQ}"39;49;00m"
COL_LYELLOW=${ESC_SEQ}"33;01m"
COL_LGREEN=${ESC_SEQ}"32;01m"
COL_CYAN=${ESC_SEQ}"0;36m"
COL_GREEN=${ESC_SEQ}"0;32m"
COL_MAGENTA=${ESC_SEQ}"0;35m"

CONTAINER_APP="app"
CONTAINER_MYSQL="mysql"
CONTAINER_NODE="node"

UNAMEOUT="$(uname -s)"

case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    MINGW64_NT-10.0*)   MACHINE=mingw64;;
    *)                  MACHINE="UNKNOWN"
esac

if [[ "$MACHINE" == "UNKNOWN" ]]; then
    echo "Unsupported system type"
    echo "System must be a Macintosh, Linux or Windows"
    echo ""
    echo "System detection determined via uname command"
    echo "If the following is empty, could not find uname command: $(which uname)"
    echo "Your reported uname is: $(uname -s)"
fi

# Set environment variables for dev
if [[ "$MACHINE" == "linux" ]]; then
    if grep -q Microsoft /proc/version; then # WSL
        export XDEBUG_HOST=10.0.75.1
    else
        if [[ "$(command -v ip)" ]]; then
            export XDEBUG_HOST=$(ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
        else
            export XDEBUG_HOST=$(ifconfig docker0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
        fi
    fi
    SEDCMD="sed -i"
elif [[ "$MACHINE" == "mac" ]]; then
    export XDEBUG_HOST=$(ipconfig getifaddr en0) # Ethernet

    if [[ -z "$XDEBUG_HOST" ]]; then
        export XDEBUG_HOST=$(ipconfig getifaddr en1) # Wifi
    fi
    SEDCMD="sed -i .bak"
elif [[ "$MACHINE" == "mingw64" ]]; then # Git Bash
    export XDEBUG_HOST=10.0.75.1
    SEDCMD="sed -i"
fi

export APP_PORT=${APP_PORT:-80}
export MYSQL_PORT=${MYSQL_PORT:-3306}
export WWWUSER=${WWWUSER:-$UID}

if [[ -f .env ]]; then
    source .env
fi

COMPOSE=$(which docker-compose)
if [[ ! -z "$COMPOSE" ]]; then
     EXEC="no"
else
    COMPOSE="COMPOSE_PROJECT_NAME=$APP_NAME docker-compose -f .docker/docker-compose.yml"
    PSRESULT="$($COMPOSE ps -q)"
    if [[ ! -z "$PSRESULT" ]]; then
        EXEC="yes"
    else
        EXEC="no"
    fi
fi

