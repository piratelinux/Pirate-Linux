#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir"/bitcoin ] && [ ! "$(ls -A $maindir/bitcoin)" ]
then 

    tar -xjf wxWidgets-2.9.2.tar.bz2
    cd wxWidgets-2.9.2
    mkdir buildgtk
    cd buildgtk
    ../configure --prefix="$maindir"/ins --with-gtk --enable-debug --disable-shared --enable-monolithic --without-libpng --disable-svg
    set +e
    make
    make install
    set -e
    cd ../..
    rm -rf wxWidgets-2.9.2
    
    tar -xzf miniupnpc-1.6.tar.gz
    cd miniupnpc-1.6
    set +e
    make
    set -e
    INSTALLPREFIX="$maindir"/ins make install
    cd ..
    rm -rf miniupnpc-1.6

    export PATH="$maindir"/ins/bin:$PATH
    export LIBRARY_PATH="$maindir"/ins/lib:$LIBRARY_PATH
    export C_INCLUDE_PATH="$maindir"/ins/include:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH="$maindir"/ins/include:$CPLUS_INCLUDE_PATH
    tar -xzf bitcoin-bitcoin-v0.3.24-0-gf087364.tar.gz
    cp net.cpp bitcoin-bitcoin-36aa6bd/src/
    cd bitcoin-bitcoin-36aa6bd/src
    set +e
    make -f makefile.unix
    set -e

    cp bitcoin "$maindir"/bitcoin/
    cd ../..
    rm -rf bitcoin-bitcoin-36aa6bd

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
