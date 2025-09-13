#!/usr/bin/env bash

. ./scripts/host/shared/config.sh

cp .env.template .env

sed -i 's/<CLUSTER>/'"$(get_cluster_name)"'/g' .env
