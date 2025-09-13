declare -a ALL_NODES=(node-1 node-2 node-3)
declare -a ALL_NODE_IDS=(1 2 3)

bold() {
    printf "$(tput bold)%s$(tput sgr0)" "$(cat)"
}

all_nodes() {
    echo -n "${ALL_NODES[*]}"
}

all_node_ids() {
    echo -n "${ALL_NODE_IDS[*]}"
}

is_valid_node() {
    local candidate="$1"

    for node in "${ALL_NODES[@]}"; do
        if [ "${candidate}" = "${node}" ]; then
            true; return
        fi
    done

    >&2 echo "Invalid node $(bold <<< "${candidate}"), valid nodes are: $(bold <<< "${ALL_NODES[@]}")"

    false; return
}

followers_nodes() {
    declare -a followers=()
    local leader="$1"

    for node in "${ALL_NODES[@]}"; do
        if [ "${node}" != "${leader}" ]; then
            followers+=("${node}")
        fi
    done

    echo -n "${followers[*]}"
}

mysql_in() {
    docker compose exec -T "${1}" sh -c '/scripts/mysql.sh'
}

mysql_in_router() {
    docker compose exec -T router sh -c '/scripts/mysql.sh'
}

mysqlsh_in() {
    docker compose exec -T "${1}" sh -c '/scripts/mysqlsh.sh'
}

node_transactions() {
    local node=$1

    mysql_in "$1" <<SQL
SELECT
    GTID_SUBTRACT(CONCAT(received_transaction_set, "," , @@GLOBAL.gtid_executed), "")
FROM
    performance_schema.replication_connection_status
WHERE
    channel_name = "group_replication_applier";
SQL
}

log_replication_state() {
    local node transactions

    echo "--------------------------------------------------------"
    printf "Node\t | Current GTID Set (Certified + Executed)\n"
    echo "--------------------------------------------------------"

    for node in ${ALL_NODES[@]}; do
        transactions=$(node_transactions "${node}")

        if [ -n "$transactions" ]; then
            report="$transactions"
        else
            report="<no results>"
        fi

        printf "%s\t | %s\n" "${node}" "$report"
        echo "--------------------------------------------------------"
    done
}

log_cluster_state() {
    local entrypoint=$1

    mysqlsh_in "${entrypoint}" <<JS
var cluster = dba.getCluster();
cluster.status();
cluster.listRouters();
JS
}
