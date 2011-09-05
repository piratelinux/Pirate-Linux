#!/bin/bash

set -e

curdir="$(pwd)"

cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/theme"

if [ -f "$localdir"/.installed ]
then
    while read line
    do
	if [[ "$(gconftool --get /desktop/gnome/background/picture_filename)" == "$line" ]]
	then
	    gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
	    gconftool-2 -t bool -s /desktop/gnome/background/picture_filename "true"
	    gconftool-2 -t string -s /desktop/gnome/background/picture_filename "/usr/share/backgrounds/warty-final-ubuntu.png"
	    gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
	    gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
	    gconftool-2 -t string -s /desktop/gnome/background/primary_color "#cdab07740000"
	    gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#2c2c00001e1e"
	    break
	fi
    done <"$localdir"/.installed
fi

set +e
chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
set -e