#!/bin/bash

while read line    
do    
    if [ -d $line ]
    then
	chmod u+rx $line
	cd $line
	chmod u+xr remove_$line.sh
	./remove_$name.sh
	cd ..
    fi
done <logs/.installed
