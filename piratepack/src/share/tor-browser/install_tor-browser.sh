#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/tor-browser

numprofile="$(ls .mozilla/firefox/*.tor 2>> /dev/null | wc -l)"
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
    mkdir "$profileuuid".tor

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
	echo "Name=tor" >> profiles.ini
	echo "IsRelative=1" >> profiles.ini
	echo "Path=""$profileuuid"".tor" >> profiles.ini
	echo "" >> profiles.ini
    fi

    cd

fi

profiledir=""

while read -r line
do
    profiledir="$homedir"/"$line"
    break
done < <(find ".mozilla/firefox/"*".tor" -maxdepth 0)

if [[ "$profiledir" != "" ]]
then
    if [ ! -f "$profiledir"/extensions/{437be45a-4114-11dd-b9ab-71d256d89593}.xpi ] && [ ! -d "$profiledir"/extensions/{437be45a-4114-11dd-b9ab-71d256d89593} ]
    then

	cd

	if [ ! -d .piratepack/backup ]
	then
            mkdir .piratepack/backup
	fi
	chmod u+rwx .piratepack/backup

	set +e
	numbackup="$(ls -d .piratepack/backup/firefox-tor_* 2>> /dev/null | wc -l)"
	set -e
	if [ "$numbackup" -ge "0" ]
	then
            chmod -R u+r "$profiledir"
            cp -r "$profiledir" .piratepack/backup/"firefox-tor"_"$(($numbackup + 1))"
            chmod -R a-w .piratepack/backup/"firefox-tor"_"$(($numbackup + 1))"
            rm -rf "$profiledir"/* "$profiledir"/.[!.]* "$profiledir"/..[!.]* "$profiledir"/...*
	fi

	cd "$localdir"
	tar -xzf "$curdir"/profile.tar.gz

	mv profile/* "$profiledir"/
	rmdir profile

	cd "$profiledir"

	echo 'user_pref("network.websocket.enabled", false);' >> prefs.js
	echo 'user_pref("extensions.jondofox.proxy.state", "tor");' >> prefs.js
	echo 'user_pref("extensions.jondofox.observatory.proxy", 1);' >> prefs.js
    fi

    if [ ! -f "$profiledir"/extensions/whoami@didierstevens.aq.xpi ] && [ ! -d "$profiledir"/extensions/whoami@didierstevens.aq ]
    then
	version="4"
	set +e
	versioncmd="$(firefox -version)"
	set -e

	if [[ "$versioncmd" == *"Firefox 3"* ]] || [[ "$versioncmd" == *"Iceweasel 3"* ]]
	then
            version="3"
	fi

	cd "$profiledir"

	if [ ! -d extensions ]
	then
            mkdir extensions
	fi
	chmod u+rwx extensions
	cd extensions

	if [[ "$version" != "3" ]]
	then
            if [ ! -d staged ]
            then
		mkdir staged
            fi
            chmod u+rwx staged
	fi

	cd "$curdir"
	cd ../"firefox-mods"

	if [[ "$version" == "3" ]]
        then
            unzip 'whoami@didierstevens.aq.xpi' -d "$profiledir"/extensions/'whoami@didierstevens.aq'
            echo "$profiledir"/extensions/'whoami@didierstevens.aq' >> "$localdir"/.installed
	else
	    cp 'whoami@didierstevens.aq.xpi' "$profiledir"/extensions/staged/
	    echo "$profiledir"/extensions/'whoami@didierstevens.aq.xpi' >> "$localdir"/.installed
	    echo "$profiledir"/extensions/staged/'whoami@didierstevens.aq.xpi' >> "$localdir"/.installed
	    echo "$profiledir"/extensions/'whoami@didierstevens.aq' >> "$localdir"/.installed
	    echo "$profiledir"/extensions/staged/'whoami@didierstevens.aq' >> "$localdir"/.installed
	fi
	if [[ "$version" != "3" ]]
        then
            cp 'whoami@didierstevens.aq.json' "$profiledir"/extensions/staged/
            echo "$profiledir"/extensions/staged/'whoami@didierstevens.aq.json' >> "$localdir"/.installed
        fi
    fi

    if [ -d "$profiledir"/extensions/staged ]
    then
	rmdir --ignore-fail-on-non-empty "$profiledir"/extensions/staged
    fi

fi

cd

if [ -d .vidalia ]
then
    if [ ! -d .piratepack/backup ]
    then
	mkdir .piratepack/backup
    fi
    chmod u+rwx .piratepack/backup

    set +e
    numbackup="$(ls -d .piratepack/backup/vidalia_* 2>> /dev/null | wc -l)"
    set -e
    if [ "$numbackup" -ge "0" ]
    then
	chmod -R u+r .vidalia
	cp -r .vidalia .piratepack/backup/"vidalia"_"$(($numbackup + 1))"
	chmod -R a-w .piratepack/backup/"vidalia"_"$(($numbackup + 1))"
	rm -rf .vidalia
    fi
fi

if [ -f .polipo_tor ]
then
    if [ ! -d .piratepack/backup ]
    then
        mkdir .piratepack/backup
    fi
    chmod u+rwx .piratepack/backup

    set +e
    numbackup="$(ls .piratepack/backup/polipo_* 2>> /dev/null | wc -l)"
    set -e
    if [ "$numbackup" -ge "0" ]
    then
	chmod u+r .polipo_tor
	cp .polipo_tor .piratepack/backup/"polipo_tor"_"$(($numbackup + 1))"
	chmod a-w .piratepack/backup/"polipo_tor"_"$(($numbackup + 1))"
	rm -rf .polipo_tor
    fi
fi

cp -r "$curdir/.polipo_tor" ~/

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
cp "$curdir/tor-browser.png" icons
cp "$curdir/tor-instance.png" icons
cp "$curdir/tor-irc.png" icons
if [ ! -d applications ]
 then mkdir applications
fi
cp "$curdir/tor-browser.desktop" applications
cp "$curdir/tor-instance.desktop" applications
cp "$curdir/tor-irc.desktop" applications
