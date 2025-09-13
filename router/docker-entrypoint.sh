#!/usr/bin/env bash

set -u

CONF_FILE="${HOME}/mysqlrouter.conf"

if [ "$1" = "mysqlrouter" ]; then
    if [ ! -f "${CONF_FILE}" ]; then
        echo "Bootstrapping router..."

        mysqlrouter \
            --bootstrap \
            "${BOOTSTRAP_MYSQL_USER}@${BOOTSTRAP_MYSQL_HOST}:${BOOTSTRAP_MYSQL_PORT}" \
            --directory "${HOME}" \
            --conf-use-gr-notifications \
            --user=mysqlrouter \
            --force <<< "$(cat "$BOOTSTRAP_MYSQL_PASSWORD_FILE")" || exit 1
    fi

    echo "Starting router..."

    exec "$@" --config "${CONF_FILE}"
else
    exec "$@"
fi
