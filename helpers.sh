showVersion() {
    intro="\nðŸ³ ${COL_GREEN}Baship for Docker${COL_RESET}\n"
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
}

selfUpdate() {
  curl -s -L "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o $0
  echo "Update Successfully"
  exit 0
}

installDocker() {
	wget -q -O - "http://get.docker.com"  | bash
    curl -s -L "$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url.*docker-compose-$(uname -s)-$(uname -m)\"" | cut -d '"' -f 4 )" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	exit 0
}

installSelf() {
    curl -s -L "$(curl -s https://api.github.com/repos/Xicy/baship/releases/latest | grep "browser_download_url.*"  | cut -d '"' -f 4)" -o /usr/local/bin/baship
	chmod +x /usr/local/bin/baship
	exit 0
}

