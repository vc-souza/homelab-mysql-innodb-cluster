#!/usr/bin/env bash

. ./scripts/host/shared/utils.sh

log() {
    printf "[dba] %s\n" "$1"
}

log "Creating a new MySQL user..."

read -p "Username: " USER

if [ ! -n "${USER}" ]; then
    >&2 log "No username provided"
    exit 1
fi

PASSWORD="$(systemd-ask-password --emoji=no "Password:")"

if [ ! -n "${PASSWORD}" ]; then
    >&2 log "No password provided"
    exit 1
fi

mysql_in_router <<SQL
CREATE USER ${USER}@'%' IDENTIFIED BY '${PASSWORD}';
SQL

log "Users for $(bold <<< "any") host:"

mysql_in_router <<'SQL'
SELECT `User` FROM mysql.user WHERE `Host`='%';
SQL
