#!/bin/bash

set -e

cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/firefox-mods"

if [ -f "$localdir"/.installed ]
then
    while read line    
    do    
	if [ -e "$line" ]
	then 
	    chmod -R u+rw "$line"
	    rm -rf "$line"
	fi
    done <"$localdir"/.installed 
fi

set +e
chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
set -e

cd

profiledir=""

while read -r line
do
    profiledir="$homedir"/"$line"
    break
done < <(find ".mozilla/firefox/"*".default" -maxdepth 0)

cd "$profiledir"

match="$(grep -nr piratelinux.org prefs.js)"
if [[ "$match" != "" ]]
then
    echo 'user_pref("browser.startup.homepage", "about:blank");' >> prefs.js
fi
