#!/bin/bash

set -e

basedir="/opt/piratepack"

set +e
rm -r "$basedir"
set -e

rm -f /usr/bin/piratepack

file=$(</etc/profile)
echo "$file" | {
    while read line; do
        if [[ "$line" != *"$basedir"* ]]; then
            echo "$line"
        fi
    done
} > /etc/profile
