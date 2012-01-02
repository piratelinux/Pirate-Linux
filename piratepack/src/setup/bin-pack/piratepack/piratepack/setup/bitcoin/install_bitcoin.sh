#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

cd db_build
cp -r bin/* /usr/bin
cp -r include/* /usr/include
cp -r lib/* /usr/lib
cd ..

cd miniupnpc_build
cp -r bin/* /usr/bin
cp -r include/* /usr/include
cp -r lib/* /usr/lib
cd ..

if [ -d "$maindir"/bitcoin ] && [ ! "$(ls -A $maindir/bitcoin)" ]
then
    mv -f bitcoind "$maindir"/bitcoin/
    mv -f bitcoin-qt "$maindir"/bitcoin/
    mv -f cwallet "$maindir"/bitcoin/
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin ]
then
    ln -s "$maindir"/bitcoin/bitcoind "$maindir"/bin/bitcoind
    ln -s "$maindir"/bitcoin/bitcoin-qt "$maindir"/bin/bitcoin-qt
    ln -s "$maindir"/bitcoin/cwallet "$maindir"/bin/cwallet
fi

echo "Exec=$maindir/bin/bitcoin-qt" >> bitcoin.desktop
cp bitcoin.desktop "$maindir/share/bitcoin/"
cp bitcoin.png "$maindir/share/bitcoin/"
