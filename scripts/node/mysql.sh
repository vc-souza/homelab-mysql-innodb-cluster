#!/usr/bin/env bash

STDIN="$(cat)"

2>/dev/null mysql \
    -h 127.0.0.1 \
    -P 3306 \
    --silent \
    --skip-column-names \
    -uroot \
    -p"$(cat /run/secrets/root)" <<EOF
$STDIN
EOF
