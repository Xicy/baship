#!/bin/b
#VERSION
#CONSTANTS
#HELPERS

#exportDockerFiles $0
#selfUpdate $0
#installDocker
#installSelf 

if [ $# -gt 0 ]; then
    if [ -f .env ]; then
        source .env
    fi
    if [ "$1" == "--version" ] || [ "$1" == "-v" ] || [ "$1" == "version" ]; then
        showVersion
        exit 1
    fi
    if [ "$1" == "--help" ] || [ "$1" == "-H" ] || [ "$1" == "help" ]; then
        showHelp
        exit 1
    fi

      if [ "$1" == "install" ]; then
        installSelf
	elif [ "$1" == "update" ]; then
        selfUpdate $0
	elif [ "$1" == "export" ]; then
        exportDockerFiles $0
    else
		echo "compose $@"
        #$COMPOSE "$@"
    fi
else
	echo "compose ps"
    #$COMPOSE ps
fi
