#!/usr/bin/env bash

STDIN="$(cat)"

# R/W-splitting
2>/dev/null mysql \
    -h 127.0.0.1 \
    -P 6450 \
    -uroot \
    -p"$(cat /run/secrets/root)" <<EOF
$STDIN
EOF
