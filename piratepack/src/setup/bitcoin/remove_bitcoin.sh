#!/bin/bash

set -e

maindir="$1"

if [ -d "$maindir"/bitcoin ] && [ "$(ls -A $maindir/bitcoin)" ]
then 
    rm -rf "$maindir"/bitcoin/*
fi
