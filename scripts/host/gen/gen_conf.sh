#!/usr/bin/env bash

. ./scripts/host/shared/config.sh

CLUSTER="$(get_cluster_name)"
REPLICATION_GROUP="$(uuidgen)"
REPLICATION_GROUP="${REPLICATION_GROUP^^}"

generate_cnf() {
    local node_id="$1"
    local src_type="$2"
    local dst_type="$3"
    local cnf="conf/node-${dst_type}${node_id}.cnf"

    rm -f "$cnf"

    cp "conf/templates/node-${src_type}.cnf" "$cnf"

    sed -i 's/<NODE_ID>/'"$node_id"'/g' "$cnf"
    sed -i 's/<CLUSTER>/'"$CLUSTER"'/g' "$cnf"
    sed -i 's/<REPLICATION_GROUP>/'"$REPLICATION_GROUP"'/g' "$cnf"
}

for NODE_ID in 1 2 3; do
    generate_cnf "$NODE_ID" "setup" ""
    generate_cnf "$NODE_ID" "final" "final-"
    generate_cnf "$NODE_ID" "restore" "restore-"
done
