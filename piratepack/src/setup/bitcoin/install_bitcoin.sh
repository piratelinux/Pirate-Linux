#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir" ]
then 

    tar -xzf db-4.8.30.tar.gz
    cd db-4.8.30/build_unix
    ../dist/configure --prefix="$maindir"/share/db_build --enable-cxx
    set +e
    make
    make install
    set -e
    cd ../..
    rm -rf db-4.8.30

    tar -xzf miniupnpc-1.6.tar.gz
    cd miniupnpc-1.6
    set +e
    make INSTALLPREFIX="$maindir"/share/miniupnpc_build install
    set -e
    cd ..
    rm -rf miniupnpc-1.6

    tar -xzf boost_1_46_1.tar.gz
    cd boost_1_46_1
    set +e
    ./bootstrap.sh --prefix="$maindir"/share/boost_build --with-libraries=filesystem,program_options,system,thread
    ./bjam install
    set -e
    cd ..
    rm -r boost_1_46_1

    tar -xzf bitcoin-bitcoin-v0.5.1-0-gb12fc3e.tar.gz
    cd bitcoin-bitcoin-5623ee7
    cp ../bitcoin-qt.pro .
    CUSTOM_INC="$maindir"/share/ssl_build/include
    CUSTOM_INC+=" "
    CUSTOM_INC+="$maindir"/share/db_build/include
    CUSTOM_INC+=" "
    CUSTOM_INC+="$maindir"/share/miniupnpc_build/include
    CUSTOM_INC+=" "
    CUSTOM_INC+="$maindir"/share/boost_build/include
    export CUSTOM_INC
    set +e
    qmake
    set -e
    export CUSTOM_INC=""
    SUBLIBS=-L"$maindir"/share/ssl_build/lib
    SUBLIBS+=" "
    SUBLIBS+=-L"$maindir"/share/db_build/lib
    SUBLIBS+=" "
    SUBLIBS+=-L"$maindir"/share/miniupnpc_build/lib
    SUBLIBS+=" "
    SUBLIBS+=-L"$maindir"/share/boost_build/lib
    export SUBLIBS
    set +e
    make
    set -e
    export SUBLIBS=""
    mkdir -p "$maindir"/share/bitcoin_build/client
    cp bitcoin-qt "$maindir"/share/bitcoin_build/client/
    cd src
    cp ../../makefile.unix .
    export OPENSSL_INCLUDE_PATH="$maindir"/share/ssl_build/include
    export OPENSSL_LIB_PATH="$maindir"/share/ssl_build/lib
    export BDB_INCLUDE_PATH="$maindir"/share/db_build/include
    export BDB_LIB_PATH="$maindir"/share/db_build/lib
    export MINIUPNPC_INCLUDE_PATH="$maindir"/share/miniupnpc_build/include
    export MINIUPNPC_LIB_PATH="$maindir"/share/miniupnpc_build/lib
    export BOOST_INCLUDE_PATH="$maindir"/share/boost_build/include
    export BOOST_LIB_PATH="$maindir"/share/boost_build/lib
    set +e
    make -f makefile.unix
    strip bitcoind
    set -e
    export OPENSSL_INCLUDE_PATH=""
    export OPENSSL_LIB_PATH=""
    export BDB_INCLUDE_PATH=""
    export BDB_LIB_PATH=""
    export MINIUPNPC_INCLUDE_PATH=""
    export MINIUPNPC_LIB_PATH=""
    export BOOST_INCLUDE_PATH=""
    export BOOST_LIB_PATH=""
    cp bitcoind "$maindir"/share/bitcoin_build/client/
    cd ../..
    rm -rf bitcoin-bitcoin-5623ee7

    tar -xzf cwallet-0.1.tar.gz
    cd cwallet-0.1
    set +e
    ./configure
    make
    set -e
    cd src
    INCLUDES=-I"$maindir"/share/ssl_build/include
    INCLUDES+=" "
    INCLUDES+=-I"$maindir"/share/db_build/include
    LIBS=-L"$maindir"/share/ssl_build/lib
    LIBS+=" "
    LIBS+=-L"$maindir"/share/db_build/lib
    export INCLUDES
    export LIBS
    set +e
    make -f makefile.static
    set -e
    export INCLUDES=""
    export LIBS=""
    mkdir -p "$maindir"/share/bitcoin_build/cwallet
    cp cwallet "$maindir"/share/bitcoin_build/cwallet/
    cp cwallet-gui "$maindir"/share/bitcoin_build/cwallet/
    cp logo.png "$maindir"/share/bitcoin_build/cwallet/
    cp icon.png "$maindir"/share/bitcoin_build/cwallet/
    cp icon.png ../../cwallet.png
    cd ../..
    rm -rf cwallet-0.1

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoin-qt ]
    then
	ln -s "$maindir"/share/bitcoin_build/client/bitcoin-qt "$maindir"/bin/bitcoin-qt
    fi
    
    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/bitcoind ]
    then
        ln -s "$maindir"/share/bitcoin_build/client/bitcoind "$maindir"/bin/bitcoind
    fi

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/cwallet ]
    then
        ln -s "$maindir"/share/bitcoin_build/cwallet/cwallet "$maindir"/bin/cwallet
    fi

    if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/cwallet-gui ]
    then
        ln -s "$maindir"/share/bitcoin_build/cwallet/cwallet-gui "$maindir"/bin/cwallet-gui
    fi

    echo "Exec=$maindir/bin/bitcoin-qt" >> bitcoin.desktop
    cp bitcoin.desktop "$maindir/share/bitcoin/"
    cp bitcoin.png "$maindir/share/bitcoin/"

    echo "Exec=$maindir/bin/cwallet-gui" >> cwallet.desktop
    cp cwallet.desktop "$maindir/share/bitcoin/"
    cp cwallet.png "$maindir/share/bitcoin/"

fi
