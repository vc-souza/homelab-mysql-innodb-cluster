#!/usr/bin/env bash

STDIN="$(cat)"

mysqlsh \
    -h 127.0.0.1 \
    -P 3306 \
    --js \
    --interactive \
    --quiet-start=2 \
    -uroot \
    -p"$(cat /run/secrets/root)" <<EOF
$STDIN
EOF
