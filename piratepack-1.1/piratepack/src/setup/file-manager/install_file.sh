#!/bin/bash
targetname=$1
targetdir="$targetname"_"pirate"
if [ -d $targetdir ]
then
    cd $targetdir
    chmod -R u+r *
    if [ -d $targetname ]
    then
	cp $targetname.tar.gz ../../$targetname
	cp $targetname.tar.gz.asc ../../$targetname
	cd ../..
	if [ ! -d backup ]
	then
	    mkdir backup
	    chmod u+rwx backup
	fi
	numbackup=$(ls backup/ppcavpn_*.pirate | wc -l)
	cp tmp/backup.pirate backup/"$targetname"_"$(($numbackup + 1)).pirate"
	cd $targetname
	chmod u+rx "install"_"$targetname"_"file.sh"
	"./install"_"$targetname"_"file.sh"
    fi
fi
