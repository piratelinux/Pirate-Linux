#!/bin/bash

set -e

cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/i2p-browser"

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

rm -f .local/share/applications/i2p-browser.desktop
rm -f .local/share/icons/i2p-browser.png

rm -f .local/share/applications/i2p-irc.desktop
rm -f .local/share/icons/i2p-irc.png

set -e
