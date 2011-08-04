#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/ppcavpn"
cd "$localdir"
cd ..

if [ -d backup ] 
then
    chmod u+rwx backup
    numbackup="$(ls backup/ppcavpn_*.pirate 2>> /dev/null | wc -l)"
    if [ "$numbackup" -ge "1" ]
    then
	if [ ! -d tmp ]
	then
	    mkdir tmp
	    chmod u+rwx tmp
	fi
	
	chmod u+r "backup/ppcavpn"_"$numbackup.pirate"
	cp "backup/ppcavpn"_"$numbackup.pirate" tmp
	chmod u+rw "backup/ppcavpn"_"$numbackup.pirate"
	mv "backup/ppcavpn"_"$numbackup.pirate" "backup/ppcavpn"_"$numbackup.pirate"_"temp"
	chmod u-w "backup/ppcavpn"_"$numbackup.pirate"_"temp"
	cd tmp
	fileinfo="$($curdir/../file-manager/get_file_info.sh ppcavpn_$numbackup.pirate)"
	if [[ "$fileinfo" == "out:"* ]]
	then
	    targetname="${fileinfo:4}"
	    verified="$($curdir/../file-manager/verify_file.sh "ppcavpn"_"$numbackup.pirate" $targetname)"
	    if [[ "$verified" == "out:verified" ]]
	    then
		cd "$curdir"
		cd ../file-manager
		./install_file.sh "$targetname" "$homedir/.piratepack/tmp"
		cd "$homedir/.piratepack/tmp"
	    fi
	fi
	cd ..
	if [ -f "backup/ppcavpn"_"$numbackup.pirate" ]
	then
	    chmod u+rw "backup/ppcavpn"_"$numbackup.pirate"_"temp"
	    rm -rf "backup/ppcavpn"_"$numbackup.pirate"_"temp"
	else
	    chmod u+rw "backup/ppcavpn"_"$numbackup.pirate"_"temp"
	    mv "backup/ppcavpn"_"$numbackup.pirate"_"temp" "backup/ppcavpn"_"$numbackup.pirate"
	fi
	
	rm -rf tmp/*
    fi
fi
