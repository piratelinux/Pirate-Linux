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
    rm -f "backup/ppcavpn"_"$numbackup.pirate" 
    cd tmp
    chmod u+rx ../file-manager/install_file.sh
    ../file-manager/install_file.sh "ppcavpn"_"$numbackup.pirate"
fi
