#@IgnoreInspection BashAddShebang
ver() { printf "%03d%03d%03d" $(echo "$1" | tr '.' ' '); }
amIRoot() { [[ "$(id -u)" -eq 0 ]]; }

showVersion() {
    intro="\n🐳  ${COL_GREEN}Baship for Docker${COL_RESET}"
    intro="$intro   ${COL_CYAN}Version ${VERSION}\n${COL_RESET}"

    printf "$intro"
}

showHelp() {

    showVersion

    usage="${COL_LYELLOW}Usage:\n${COL_RESET}"
    usage="$usage  baship <cmd> <options>"

    commands="${COL_LYELLOW}Commands:\n${COL_RESET}"
    commands="$commands  art | artisan <cmd>         Run Laravel Artisan CLI in ${COL_MAGENTA}${CONTAINER_APP}${COL_RESET} container\n"
    commands="$commands  composer <cmds>             Run Composer in ${COL_MAGENTA}${CONTAINER_APP}${COL_RESET} container\n"
    commands="$commands  mysql                       Run MySQL CLI in ${COL_MAGENTA}${CONTAINER_MYSQL}${COL_RESET} container\n"
    commands="$commands  dump (autoload)             Performs composer dump-autoload in ${COL_MAGENTA}${CONTAINER_APP}${COL_RESET} container\n"
    commands="$commands  exec <container>            Execute a command in a running container\n"
    commands="$commands  help                        Shows Help screen\n"
    commands="$commands  logs <container> < -f >     Displays all logs for <container> and optionally tail\n"
    commands="$commands  npm                         Execute npm command using ${COL_MAGENTA}${CONTAINER_NODE}${COL_RESET} container\n"
    commands="$commands  ps                          Display list of all running containers in current directory\n"
    commands="$commands  start < -l >                Starts all containers defined in ${COL_LGREEN}docker-compose.yml${COL_RESET} file\n"
    commands="$commands  stop                        Stops all containers defined in ${COL_LGREEN}docker-compose.yml${COL_RESET} file\n"
    commands="$commands  test [params]               Runs PHPUnit using supplied options in ${COL_MAGENTA}${CONTAINER_APP}${COL_RESET} container\n"
    commands="$commands  tinker                      Runs Tinker in ${COL_MAGENTA}${CONTAINER_APP}${COL_RESET} container\n"
    commands="$commands  npm <options>               Runs npm using supplied options in ${COL_MAGENTA}${CONTAINER_NODE}${COL_RESET} container\n"
    commands="$commands  yarn <options>              Runs yarn using supplied options in ${COL_MAGENTA}${CONTAINER_NODE}${COL_RESET} container\n"
#    commands="$commands  gulp <task>                 Runs gulp task in ${COL_MAGENTA}${CONTAINER_NODE}${COL_RESET} container\n"

    options="${COL_LYELLOW}Options:\n${COL_RESET}"
    options="$options --help, -h                   Shows Help (this screen)\n"
#    options="$options --logs, -l                   Run containers in detached mode (with logging)\n"
    options="$options --version, -V, version       Show Version\n"

    examples="${COL_LYELLOW}Examples:\n${COL_RESET}"
    examples="$examples  ${COL_CYAN}$ baship start${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship stop${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship dump${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship logs # all container logs${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship composer require <vendor/package>${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship mysql${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship artisan migrate --seed${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship art db:seed${COL_RESET}\n"
    examples="$examples  ${COL_CYAN}$ baship test --filter=MyFilter${COL_RESET}\n"

    printf "\n"
    printf "$usage\n\n"
    printf "$commands\n"
    printf "$options\n"
    printf "$examples\n"

}

exportDockerFiles() {
  sed '1,/^_DATA_/d' $0 | tar xzf - --no-same-owner
  printf "${COL_LGREEN}Exporting Successfully${COL_RESET}\n"
}

updateSelf() {
  if ! amIRoot; then
    sudo $0 $@
    return
  fi
  DATA=$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest)
  LASTESTVERSION=$(echo "$DATA" | grep "tag_name.*"  | cut -d '"' -f 4 )
  if [ $(expr $(ver ${LASTESTVERSION}) - $(ver ${VERSION})) -gt 0 ]; then
    curl -s -L "$(echo "$DATA" | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o $0
    printf "${COL_LGREEN}Update Successfully ( ${VERSION} -> ${LASTESTVERSION} )${COL_RESET}\n"
    exit 0
  else
    printf "${COL_LGREEN}This is latest version: ${VERSION}${COL_RESET}\n"
  fi
}

installDocker() {
    curl -s -L "http://get.docker.com" -o - | sh
    curl -s -L "$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*docker-compose-$(uname -s)-$(uname -m)\"" | cut -d '"' -f 4 )" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	printf "${COL_LGREEN}Docker Installing Successfully${COL_RESET}\n"
}

installSelf() {
    if ! amIRoot; then
        printf "${COL_MAGENTA}Must run as root${COL_RESET}\n"
        return
    fi

    curl -s -L "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o /usr/local/bin/baship
	chmod +x /usr/local/bin/baship
	if [ -z "$( grep "bin/baship" /etc/sudoers)" ]; then
        echo "ALL     ALL=(ALL)       NOPASSWD:/usr/local/bin/baship update" >> /etc/sudoers
    fi
	printf "${COL_LGREEN}Baship Installing Successfully${COL_RESET}\n"
}

setEnv(){
    if [ ! -z "$(grep "$2" "$1")" ]; then
        $SEDCMD "s/$2=$4$/$2=$3/" "$1"
    else
        echo "$2=$3" >> "$1"
    fi
}

initProject(){
	echo "BASHIP: Initializing Baship..."
    if [ ! -d .docker ]; then
        exportDockerFiles $@
    fi

	if [ ! -f ${envFile} ] && [ -f "$(pwd)/.env.example" ]; then
		cp "$envFile.example" ${envFile}
	fi

    if [ ! -f ${envFile} ]; then
        echo "No .env file found within current working directory $(pwd)"
        echo "Create a .env file before re-initializing"
        exit 1
    fi

    echo "BASHIP: Setting .env Variables"
    cp ${envFile} "$envFile.bak.baship"

    setEnv ${envFile} "APP_NAME" "$COMPOSE_PROJECT_NAME"
    setEnv ${envFile} "SERVICES" "\"$SERVICES\""
    setEnv ${envFile} "DB_USERNAME" "laravel" ".*"
    setEnv ${envFile} "DB_HOST" "mysql" ".*"
    setEnv ${envFile} "DB_PASSWORD" "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
    setEnv ${envFile} "CACHE_DRIVER" "redis" ".*"
    setEnv ${envFile} "SESSION_DRIVER" "redis" ".*"
    setEnv ${envFile} "REDIS_HOST" "redis" ".*"

    if [ -f "$envFile.bak" ]; then
        rm "$envFile.bak"
    fi

    echo "BASHIP: Installing Predis"
    exec $0 composer require predis/predis

    echo ""
    echo "BASHIP: Complete!"
    echo "BASHIP: You can now use Baship"
    echo "BASHIP: Try starting it:"
    echo "baship start"
}
