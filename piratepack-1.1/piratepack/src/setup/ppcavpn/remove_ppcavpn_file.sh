#!/bin/bash

curdir="$(pwd)"

if [ -f ppcavpn/.installed ]
then
    while read line    
    do    
	gconftool-2 --recursive-unset $line    
    done <ppcavpn/.installed     
fi

chmod -R u+rw ppcavpn
rm -rf ppcavpn
