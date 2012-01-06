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
    mv -f client "$maindir"/bitcoin/
    mv -f cwallet "$maindir"/bitcoin/
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin ]
then
    ln -s "$maindir"/bitcoin/client/bitcoind "$maindir"/bin/bitcoind
    ln -s "$maindir"/bitcoin/client/bitcoin-qt "$maindir"/bin/bitcoin-qt
    ln -s "$maindir"/bitcoin/cwallet/cwallet "$maindir"/bin/cwallet
    ln -s "$maindir"/bitcoin/cwallet/cwallet-gui "$maindir"/bin/cwallet-gui
fi

echo "Exec=$maindir/bin/bitcoin-qt" >> bitcoin.desktop
cp bitcoin.desktop "$maindir/share/bitcoin/"
cp bitcoin.png "$maindir/share/bitcoin/"

echo "Exec=$maindir/bin/cwallet-gui" >> cwallet.desktop
cp cwallet.desktop "$maindir/share/bitcoin/"
cp cwallet.png "$maindir/share/bitcoin/"
