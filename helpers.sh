#@IgnoreInspection BashAddShebang
ver() { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

showVersion() {
    intro="\n🐳 ${COL_GREEN}Baship for Docker${COL_RESET}"
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
  sed '1,/^_DATA_/d' $0 | tar xzf -
  printf "${COL_LGREEN}Exporting Successfully${COL_RESET}\n"
}

updateSelf() {
  DATA=$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest)
  LASTESTVERSION=$(echo "$DATA" | grep "tag_name.*"  | cut -d '"' -f 4 )
  if [[ $((10#$(ver ${VERSION}))) -lt $((10#$(ver ${LASTESTVERSION}))) ]]; then
    sudo curl -s -L "$(echo "$DATA" | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o $0
    printf "${COL_LGREEN}Update Successfully ( ${VERSION} -> ${LASTESTVERSION} )${COL_RESET}\n"
    exit 0
  else
    printf "${COL_LGREEN}This is latest version: ${VERSION}${COL_RESET}\n"
  fi
}

installDocker() {
	sudo wget -q -O - "http://get.docker.com"  | bash
    sudo curl -s -L "$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*docker-compose-$(uname -s)-$(uname -m)\"" | cut -d '"' -f 4 )" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	printf "${COL_LGREEN}Docker Installing Successfully${COL_RESET}\n"
}

installSelf() {
    sudo curl -s -L "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o /usr/local/bin/baship
	sudo chmod +x /usr/local/bin/baship
	if [[ -z "$(sudo grep "bin/baship" /etc/sudoers)" ]]; then
        sudo echo "$(whoami)     ALL=(ALL)       NOPASSWD:/usr/local/bin/baship" >> /etc/sudoers
    fi
	printf "${COL_LGREEN}Baship Installing Successfully${COL_RESET}\n"
}

initProject(){
	echo "BASHIP: Initializing Baship..."
    if [[ ! -d .docker ]]; then
        exportDockerFiles $@
    fi

    COMPOSER=$(which composer)
    echo "BASHIP: Installing Predis"
    if [[ -z "$COMPOSER" ]]; then
      if [[ "$EXEC" == "yes" ]]; then
        $COMPOSE exec -u baship app composer require predis/predis
      else
        $COMPOSE run --rm app composer require predis/predis
      fi
    else
        $COMPOSER require predis/predis
    fi

	if [[ ! -f "$(pwd)/.env" ]] && [[ -f "$(pwd)/.env.example" ]]; then
		cp "$(pwd)/.env.example" "$(pwd)/.env"
	fi

    if [[ ! -f "$(pwd)/.env" ]]; then
        echo "No .env file found within current working directory $(pwd)"
        echo "Create a .env file before re-initializing"
        exit 1
    fi

    echo "BASHIP: Setting .env Variables"
    cp .env .env.bak.baship

    if [[ ! -z "$(grep "DB_HOST" "$(pwd)/.env")" ]]; then
        $SEDCMD "s/DB_HOST=.*/DB_HOST=mysql/" "$(pwd)/.env"
    else
        echo "DB_HOST=mysql" >> "$(pwd)/.env"
    fi

    if [[ ! -z "$(grep "CACHE_DRIVER" "$(pwd)/.env")" ]]; then
        $SEDCMD "s/CACHE_DRIVER=.*/CACHE_DRIVER=redis/" "$(pwd)/.env"
    else
        echo "CACHE_DRIVER=redis" >> "$(pwd)/.env"
    fi

    if [[ ! -z "$(grep "SESSION_DRIVER" "$(pwd)/.env")" ]]; then
        $SEDCMD "s/SESSION_DRIVER=.*/SESSION_DRIVER=redis/" "$(pwd)/.env"
    else
        echo "SESSION_DRIVER=redis" >> "$(pwd)/.env"
    fi

    if [[ ! -z "$(grep "REDIS_HOST" "$(pwd)/.env")" ]]; then
        $SEDCMD "s/REDIS_HOST=.*/REDIS_HOST=redis/" "$(pwd)/.env"
    else
        echo "REDIS_HOST=redis" >> "$(pwd)/.env"
    fi

    if [[ -f "$(pwd)/.env.bak" ]]; then
        rm "$(pwd)/.env.bak"
    fi

    echo ""
    echo "BASHIP: Complete!"
    echo "BASHIP: You can now use Baship"
    echo "BASHIP: Try starting it:"
    echo "baship start"
}
