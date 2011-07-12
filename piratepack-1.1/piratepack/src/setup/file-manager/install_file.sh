#!/bin/bash
chmod u+r $1
mv $1 original.pirate 
cp original.pirate backup.pirate
chmod u-w backup.pirate
tar -xzf original.pirate
targetdir=$(find *_pirate -maxdepth 0)
targetdirlen=${#targetdir}
targetdirlensub=$(($targetdirlen - 7))
targetname=${targetdir:0:$targetdirlensub}
chmod u+rx $targetdir
if [ -d $targetdir ]
then  
    cd $targetdir
    chmod -R u+r *
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
    chmod -R u+rw tmp
    rm -rf tmp
    cd $targetname
    chmod u+rx "install"_"$targetname"_"file.sh"
    "./install"_"$targetname"_"file.sh"
else
    cd ..
    chmod -R u+rw tmp
    rm -rf tmp
fi
