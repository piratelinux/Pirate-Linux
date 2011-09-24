#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir"/bitcoin ] && [ ! "$(ls -A $maindir/bitcoin)" ]
then
    cp bitcoin "$maindir"/bitcoin/
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin ]
then
    ln -s "$maindir"/bitcoin/bitcoin "$maindir"/bin/bitcoin
fi

echo "Exec=$maindir/bin/bitcoin" >> bitcoin.desktop
cp bitcoin.desktop "$maindir/share/bitcoin/"
cp bitcoin.png "$maindir/share/bitcoin/"
