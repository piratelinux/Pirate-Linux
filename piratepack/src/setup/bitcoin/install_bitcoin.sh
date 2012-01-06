#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir"/bitcoin ] && [ ! "$(ls -A $maindir/bitcoin)" ]
then 

    tar -xzf db-4.8.30.tar.gz
    cd db-4.8.30/build_unix
    ../dist/configure --prefix="$curdir"/db_build --enable-cxx
    set +e
    make
    make install
    set -e
    cd ../..
    cd db_build
    cp -r bin/* /usr/bin
    cp -r include/* /usr/include
    cp -r lib/* /usr/lib
    rm -r docs
    cd ..
    mv db_build "$maindir"/tmp
    rm -rf db-4.8.30    
    
    tar -xzf miniupnpc-1.6.tar.gz
    cd miniupnpc-1.6
    set +e
    INSTALLPREFIX="$curdir"/miniupnpc_build make install
    set -e
    cd ..
    cd miniupnpc_build
    cp -r bin/* /usr/bin
    cp -r include/* /usr/include
    cp -r lib/* /usr/lib
    cd ..
    mv miniupnpc_build "$maindir"/tmp
    rm -rf miniupnpc-1.6

    tar -xzf bitcoin-bitcoin-v0.5.1-0-gb12fc3e.tar.gz
    cd bitcoin-bitcoin-5623ee7
    cp ../bitcoin-qt.pro .
    set +e
    qmake
    make
    set -e
    mkdir "$maindir"/bitcoin/client
    cp bitcoin-qt "$maindir"/bitcoin/client/
    cd src
    cp ../../makefile.unix .
    set +e
    make -f makefile.unix
    set -e
    cp bitcoind "$maindir"/bitcoin/client/
    cd ../..
    rm -rf bitcoin-bitcoin-5623ee7

    tar -xzf cwallet.tar.gz
    cd cwallet
    ./configure
    set +e
    make
    set -e
    cd src
    mkdir "$maindir"/bitcoin/cwallet
    cp cwallet "$maindir"/bitcoin/cwallet/
    cp cwallet-gui "$maindir"/bitcoin/cwallet/
    cp logo.png "$maindir"/bitcoin/cwallet/
    cp icon.png "$maindir"/bitcoin/cwallet/
    cp icon.png ../../cwallet.png
    cd ../..
    rm -rf cwallet

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin-qt ]
    then
	ln -s "$maindir"/bitcoin/client/bitcoin-qt "$maindir"/bin/bitcoin-qt
    fi
    
    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoind ]
    then
        ln -s "$maindir"/bitcoin/client/bitcoind "$maindir"/bin/bitcoind
    fi

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/cwallet ]
    then
        ln -s "$maindir"/bitcoin/cwallet/cwallet "$maindir"/bin/cwallet
    fi

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/cwallet-gui ]
    then
        ln -s "$maindir"/bitcoin/cwallet/cwallet-gui "$maindir"/bin/cwallet-gui
    fi

    echo "Exec=$maindir/bin/bitcoin-qt" >> bitcoin.desktop
    cp bitcoin.desktop "$maindir/share/bitcoin/"
    cp bitcoin.png "$maindir/share/bitcoin/"

    echo "Exec=$maindir/bin/cwallet-gui" >> cwallet.desktop
    cp cwallet.desktop "$maindir/share/bitcoin/"
    cp cwallet.png "$maindir/share/bitcoin/"

fi
