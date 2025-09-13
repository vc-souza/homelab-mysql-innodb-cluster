#!/usr/bin/env bash

. ./scripts/host/shared/config.sh
. ./scripts/host/shared/utils.sh

set -u

ENTRYPOINT_NODE="$1"

is_valid_node "${ENTRYPOINT_NODE}" || exit 1

log() {
    printf "[monitoring] %s\n" "$1"
}

log "State of MySQL InnoDB Cluster \"$(get_cluster_name | bold)\", according to $(bold <<< "${ENTRYPOINT_NODE}"):"

log_cluster_state "${ENTRYPOINT_NODE}"

log "Current replication state:"

log_replication_state
