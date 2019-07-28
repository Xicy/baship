#!/bin/bash
#VERSION
#CONSTANTS
#HELPERS

if [[ $# -gt 0 ]]; then
    if [[ "$1" == "--version" ]] || [[ "$1" == "-v" ]] || [[ "$1" == "version" ]]; then
        showVersion
        exit 0
    elif [[ "$1" == "--help" ]] || [[ "$1" == "-H" ]] || [[ "$1" == "help" ]]; then
        showHelp
        exit 0
    fi

	if [[ "$1" == "init" ]]; then
        initProject $@
    elif [[ "$1" == "install" ]]; then
        installSelf
		installDocker
	elif [[ "$1" == "update" ]]; then
        updateSelf $0
	elif [[ "$1" == "export" ]]; then
        exportDockerFiles $0
    elif [[ "$1" == "start" ]]; then
        $COMPOSE up -d "$SERVICES"
    elif [[ "$1" == "stop" ]]; then
        $COMPOSE down
    elif [[ "$1" == "php" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec -u baship ${CONTAINER_APP} php "$@"
        else
            $COMPOSE run --rm ${CONTAINER_APP} php "$@"
        fi
    elif [[ "$1" == "artisan" ]] || [[ "$1" == "art" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec -u baship ${CONTAINER_APP} php artisan "$@"
        else
            $COMPOSE run --rm ${CONTAINER_APP} php artisan "$@"
        fi
    elif [[ "$1" == "composer" ]] || [[ "$1" == "comp" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec -u baship ${CONTAINER_APP} composer "$@"
        else
            $COMPOSE run --rm ${CONTAINER_APP} composer "$@"
        fi
    elif [[ "$1" == "test" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec -u baship ${CONTAINER_APP} ./vendor/bin/phpunit "$@"
        else
            $COMPOSE run --rm ${CONTAINER_APP} ./vendor/bin/phpunit "$@"
        fi
    elif [[ "$1" == "tinker" ]] ; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec -u baship ${CONTAINER_APP} php artisan tinker
        else
            $COMPOSE run --rm ${CONTAINER_APP} php artisan tinker
        fi
    elif [[ "$1" == "node" ]]; then
        shift 1
        $COMPOSE run --rm ${CONTAINER_NODE} node "$@"
    elif [[ "$1" == "npm" ]]; then
        shift 1
        $COMPOSE run --rm ${CONTAINER_NODE} npm "$@"
    elif [[ "$1" == "yarn" ]]; then
        shift 1
        $COMPOSE run --rm ${CONTAINER_NODE} yarn "$@"
    elif [[ "$1" == "gulp" ]]; then
        shift 1
        $COMPOSE run --rm ${CONTAINER_NODE} ./node_modules/.bin/gulp "$@"
    elif [[ "$1" == "dump" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec ${CONTAINER_MYSQL} bash -c 'MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqldump -u root --default-character-set=utf8mb4 $MYSQL_DATABASE'
        else
            $COMPOSE run --rm ${CONTAINER_MYSQL} bash -c 'MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysqldump -u root --default-character-set=utf8mb4 $MYSQL_DATABASE'
        fi
    elif [[ "$1" == "mysql" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]]; then
            $COMPOSE exec ${CONTAINER_MYSQL} bash -c 'MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -u root $MYSQL_DATABASE'
        else
            echo "Error: This command can only be run while a MySQL container is running mysqld (mysql server)."
            echo "This command cannot run the server and the mysql client at the same time."
        fi
    elif [[ "$1" == "ssh" ]]; then
        shift 1
        if [[ "$EXEC" == "yes" ]] && [[ "$1" != "node" ]]; then
            $COMPOSE exec -u baship $1 bash
        else
            $COMPOSE run --rm $1 bash
        fi
    else
        $COMPOSE "$@"
    fi
else
    $COMPOSE ps
fi
