#!/usr/bin/env bash

. ./scripts/host/shared/config.sh
. ./scripts/host/shared/utils.sh

# Use the node with the most up-to-date data as the leader,
# every other node should be a follower. In case of a manual
# failover, assign the right node as the leader, using the
# replication information logged later to make a decision.

LEADER_NODE="$1"

is_valid_node "${LEADER_NODE}" || exit 1

declare -a FOLLOWER_NODES=($(followers_nodes "${LEADER_NODE}"))
declare -a ALL_NODE_IDS=($(all_node_ids))
declare -a ALL_NODES=($(all_nodes))

log() {
    printf "[restore] %s\n" "$1"
}

log "Restoring MySQL InnoDB Cluster \"$(get_cluster_name | bold)\" from complete outage"
log "Swapping configs (no replication on startup)"

for node_id in ${ALL_NODE_IDS[@]}; do
    cp "conf/node-restore-${node_id}.cnf" "conf/node-${node_id}.cnf"
done

log "Starting all nodes"

docker compose up -d ${ALL_NODES[@]}

log "Waiting for all nodes to be up and running..."

sleep 10

log "Current replication state:"

log_replication_state

log "Leader $(bold <<< "${LEADER_NODE}") is restoring the replication group..."

mysql_in $LEADER_NODE <<SQL
SET @@GLOBAL.group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET @@GLOBAL.group_replication_bootstrap_group=OFF;
SQL

for node in "${FOLLOWER_NODES[@]}"; do
    log "Follower $(bold <<< "$node") is re-joining the replication group..."
    mysql_in $node <<SQL
START GROUP_REPLICATION;
SQL
done

log "Swapping configs (replication on startup)"

for node_id in ${ALL_NODE_IDS[@]}; do
    cp "conf/node-final-${node_id}.cnf" "conf/node-${node_id}.cnf"
done

log "Starting router..."

docker compose up --build -d router

log "Done"
