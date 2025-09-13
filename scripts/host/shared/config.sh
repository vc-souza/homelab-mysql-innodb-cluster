CONFIG_FILE="config.json"

get_cluster_name() {
    cat "$CONFIG_FILE" | jq -rc '.["cluster"]'
}

get_replication_password() {
    cat "$CONFIG_FILE" | jq -rc '.["passwords"]["repl"]'
}

get_root_password() {
    cat "$CONFIG_FILE" | jq -rc '.["passwords"]["root"]'
}
