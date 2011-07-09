#!/bin/bash
while read line    
do    
    if [ -e $line ]
    then 
	chmod -R u+rw $line
	rm -r $line
    fi
done <.installed 
chmod -R u+rw *
rm -rf *
