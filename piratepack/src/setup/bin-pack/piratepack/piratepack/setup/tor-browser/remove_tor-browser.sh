#!/bin/bash

set -e

maindir="$1"

if [ -d "$maindir"/tor-browser ] && [ "$(ls -A $maindir/tor-browser)" ]
then 
    rm -r "$maindir"/tor-browser/*
fi
