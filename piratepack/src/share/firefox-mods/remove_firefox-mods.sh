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

if [ -d "$localdir" ]
then
    set +e
    chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
    rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
    set -e
fi

cd

profiledir=""

while read -r line
do
    profiledir="$homedir"/"$line"
    break
done < <(find ".mozilla/firefox/"*".default" -maxdepth 0)

cd "$profiledir"

match="$(grep homepage.*piratelinux.org prefs.js)"
if [[ "$match" != "" ]]
then
    echo 'user_pref("browser.startup.homepage", "about:blank");' >> prefs.js
fi

match="$(grep port.*8124 prefs.js)"
if [[ "$match" != "" ]]
then
    echo 'user_pref("network.proxy.http", "");' >> prefs.js
    echo 'user_pref("network.proxy.http_port", 0);' >> prefs.js
    echo 'user_pref("network.proxy.ssl", "");' >> prefs.js
    echo 'user_pref("network.proxy.ssl_port", 0);' >> prefs.js
fi

cd
set +e
rm -f .local/share/applications/firefox-pm.desktop
rm -f .local/share/icons/firefox-pm.png
set -e
