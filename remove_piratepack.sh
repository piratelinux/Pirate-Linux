#!/bin/bash

set -e

basedir="$1"

if [[ "$basedir" == "" ]]
then
    basedir="/opt/piratepack"
fi

if [ -e "$basedir" ]
then
    rm -r "$basedir"
fi

rm -f /usr/bin/piratepack

file=$(</etc/profile)
echo "$file" | {
    while read line; do
        if [[ "$line" != *"$basedir"* ]]; then
            echo "$line"
        fi
    done
} > /etc/profile
