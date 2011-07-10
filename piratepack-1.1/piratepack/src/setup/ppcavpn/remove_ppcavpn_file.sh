#!/bin/bash

curdir="$(pwd)"

while read line    
do    
    gconftool-2 --recursive-unset $line    
done <$curdir/ppcavpn/.installed 

cd ..
if [ ! -d backup ]
 then mkdir backup
fi
chmod -R u+r ppcavpn

numbackups=$(ls -d backup/ppcavpn* | wc -l)

cp -r ppcavpn/ppcavpn backup/ppcavpn-$(($numbackups + 1))
chmod -R u+rw ppcavpn/ppcavpn
rm -rf ppcavpn/ppcavpn
