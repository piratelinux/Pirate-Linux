#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/i2p-browser

numprofile="$(ls .mozilla/firefox/*.i2p 2>> /dev/null | wc -l)"
if [ "$numprofile" -lt "1" ]
then
    if [ ! -d ".mozilla" ]
    then
	mkdir .mozilla
    fi
    
    if [ ! -d ".mozilla/firefox" ]
    then
	chmod u+rwx ".mozilla"
	mkdir ".mozilla/firefox"
    fi

    chmod u+rwx ".mozilla/firefox"
    uuid="$(uuidgen)"
    profileuuid="${uuid:0:8}"
    cd ".mozilla/firefox"
    mkdir "$profileuuid".i2p

    if [ ! -f profiles.ini ]
    then
	echo "[General]" >> profiles.ini
        echo "StartWithLastProfile=1" >> profiles.ini
	echo "" >> profiles.ini

	defuuid="$(uuidgen)"
	profiledefuuid="${defuuid:0:8}"
	
	echo "[Profile0]" >> profiles.ini
        echo "Name=default" >> profiles.ini
        echo "IsRelative=1" >> profiles.ini
        echo "Path=""$profiledefuuid"".default" >> profiles.ini
	echo "Default=1" >> profiles.ini
        echo "" >> profiles.ini
    fi
    
    if [ -f profiles.ini ]
    then
	profilenum="0"
	while read line
	do
            if [[ "$line" == *"[Profile"*"]"* ]]
            then
		profilenum="$(($profilenum + 1))"
            fi
	done <profiles.ini
	
	echo "[Profile""$profilenum""]" >> profiles.ini
	echo "Name=i2p" >> profiles.ini
	echo "IsRelative=1" >> profiles.ini
	echo "Path=""$profileuuid"".i2p" >> profiles.ini
	echo "" >> profiles.ini
    fi

    cd

fi

profiledir=""

while read -r line
do
    profiledir="$homedir"/"$line"
    break
done < <(find ".mozilla/firefox/"*".i2p" -maxdepth 0)

cd "$profiledir"
echo 'user_pref("browser.startup.homepage", "http://127.0.0.1:7657");' >> prefs.js
echo 'user_pref("network.proxy.http", "127.0.0.1");' >> prefs.js
echo 'user_pref("network.proxy.http_port", 4444);' >> prefs.js
echo 'user_pref("network.proxy.ssl", "127.0.0.1");' >> prefs.js
echo 'user_pref("network.proxy.ssl_port", 4445);' >> prefs.js
echo 'user_pref("network.proxy.ftp", "127.0.0.1");' >> prefs.js
echo 'user_pref("network.proxy.ftp_port", 4444);' >> prefs.js
echo 'user_pref("network.proxy.socks", "127.0.0.1");' >> prefs.js
echo 'user_pref("network.proxy.socks_port", 4444);' >> prefs.js
echo 'user_pref("network.proxy.gopher", "127.0.0.1");' >> prefs.js
echo 'user_pref("network.proxy.gopher_port", 4444);' >> prefs.js
echo 'user_pref("network.proxy.type", 1);' >> prefs.js

cd

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
cp "$curdir/i2p-browser.png" icons
cp "$curdir/i2p-irc.png" icons
if [ ! -d applications ]
 then mkdir applications
fi
cp "$curdir/i2p-browser.desktop" applications
cp "$curdir/i2p-irc.desktop" applications
