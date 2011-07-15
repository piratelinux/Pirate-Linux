#!/bin/bash
cd ..

if [ -d backup ] 
then
    chmod u+rwx backup
    numbackup=$(ls backup/ppcavpn_*.pirate | wc -l)

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
    chmod u+rx ../file-manager/get_file_info.sh
    fileinfo=$(../file-manager/get_file_info.sh "ppcavpn"_"$numbackup.pirate")
    if [[ "$fileinfo" == "out:"* ]]
    then
	targetname=${fileinfo:4}
	chmod u+rx ../file-manager/verify_file.sh
	verified=$(../file-manager/verify_file.sh "ppcavpn"_"$numbackup.pirate" $targetname)
	if [[ "$verified" == "out:verified" ]]
	then
	    chmod u+rx ../file-manager/install_file.sh
            ../file-manager/install_file.sh $targetname
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
