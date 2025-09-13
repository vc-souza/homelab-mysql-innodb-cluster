#!/usr/bin/env bash

. ./scripts/host/shared/config.sh
. ./scripts/host/shared/utils.sh

LEADER_NODE="$1"

is_valid_node "${LEADER_NODE}" || exit 1

declare -a FOLLOWER_NODES=($(followers_nodes "${LEADER_NODE}"))
declare -a ALL_NODES=($(all_nodes))

log() {
    printf "[bootstrap] %s\n" "$1"
}

log "Setting up MySQL InnoDB Cluster \"$(get_cluster_name | bold)\""
log "Starting all nodes"

docker compose up -d ${ALL_NODES[@]}

log "Waiting for all nodes to be up and running..."

sleep 30

log "Leader $(bold <<< "${LEADER_NODE}") is bootstrapping the replication group..."

mysql_in $LEADER_NODE <<SQL
SET @@GLOBAL.group_replication_bootstrap_group=ON;

CREATE USER repl@'%' IDENTIFIED BY '$(get_replication_password)';

GRANT GROUP_REPLICATION_STREAM ON *.*  TO repl@'%';
GRANT REPLICATION SLAVE ON *.*  TO repl@'%';
GRANT CONNECTION_ADMIN ON *.*  TO repl@'%';
GRANT BACKUP_ADMIN ON *.*  TO repl@'%';

FLUSH PRIVILEGES;

CHANGE REPLICATION SOURCE TO
    SOURCE_USER='repl',
    SOURCE_PASSWORD='$(get_replication_password)'
FOR CHANNEL
    'group_replication_recovery';

START GROUP_REPLICATION;

SET @@GLOBAL.group_replication_bootstrap_group=OFF;
SQL

for node in "${FOLLOWER_NODES[@]}"; do
    log "Follower $(bold <<< "$node") is joining the replication group..."
    mysql_in $node <<SQL
RESET BINARY LOGS AND GTIDS;

CHANGE REPLICATION SOURCE TO
    SOURCE_USER='repl',
    SOURCE_PASSWORD='$(get_replication_password)'
FOR CHANNEL
    'group_replication_recovery';

START GROUP_REPLICATION;
SQL
done

log "Leader $(bold <<< "${LEADER_NODE}") is creating the cluster..."

mysqlsh_in $LEADER_NODE <<SQL
dba.createCluster('$(get_cluster_name)Cluster', {adoptFromGR: true})
SQL

log "Shutting down all nodes"

docker compose down

log "Done"
