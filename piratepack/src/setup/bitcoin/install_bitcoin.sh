#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir"/bitcoin ] && [ ! "$(ls -A $maindir/bitcoin)" ]
then 

    unzip bitcoin-bitcoin-v0.4.00rc1-0-g7464e64.zip
    cd bitcoin-bitcoin-c0b616b
    set +e
    #TODO make
    set -e
    mkdir "$maindir"/bitcoin
    cp bitcoin "$maindir"/bitcoin/
    cd ..
    rm -rf bitcoin-bitcoin-c0b616b

fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin ]
then
    ln -s "$maindir"/bitcoin/bitcoin "$maindir"/bin/bitcoin
fi

cd "$maindir"
cd ..
basedir="$(pwd)"

cd "$curdir"

echo "Exec=$maindir/bin/bitcoin" >> bitcoin.desktop
cp bitcoin.desktop "$maindir/share/bitcoin/"
cp bitcoin.png "$maindir/share/bitcoin/"
