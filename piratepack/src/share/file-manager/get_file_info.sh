#!/bin/bash

set -e

chmod u+r "$1" 
tar -xzf "$1"
targetdir="$(find *_pirate -maxdepth 0)"
if [ -d "$targetdir" ]
then
    targetdirlen="${#targetdir}"
    targetdirlensub="$(($targetdirlen - 7))"
    targetname="${targetdir:0:$targetdirlensub}"
    echo "out:$targetname"
else
    echo "err:File not recognized"
fi
