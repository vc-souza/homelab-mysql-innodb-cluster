#!/usr/bin/env bash

. ./scripts/host/shared/config.sh

get_replication_password > secrets/db/repl/pass.txt
get_root_password > secrets/db/root/pass.txt
