#!/bin/bash

set -e

cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/bitcoin"

if [ -f "$localdir/.installed" ]
then
    while read line    
    do    
	if [ -e "$line" ]
	then 
	    chmod -R u+rw "$line"
	    rm -rf "$line"
	fi
    done <"$localdir/.installed" 
fi

set +e

chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*

rm -f .local/share/applications/bitcoin.desktop
rm -f .local/share/icons/bitcoin.png

set -e
