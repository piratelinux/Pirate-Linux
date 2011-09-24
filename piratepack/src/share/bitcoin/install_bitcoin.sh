#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/bitcoin

if [ ! -d .local ]
 then mkdir .local
fi
cd .local
if [ ! -d share ]
 then mkdir share
fi
cd share
if [ ! -d icons ]
 then mkdir icons
fi
cp "$curdir/bitcoin.png" icons
if [ ! -d applications ]
 then mkdir applications
fi
cp "$curdir/bitcoin.desktop" applications
