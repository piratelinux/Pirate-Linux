#!/bin/bash

set -e

curdir="$(pwd)"

cd
homedir="$(pwd)"
localdir="$homedir/.piratepack/theme"

issue=$(cat /etc/issue)

if [ -f "$localdir"/.installed ]
then
    while read line
    do

	if [[ "$line" == "$homedir"/Pictures/pirate ]]
	then
	    rm -rf "$line"
	    continue
	fi

	if [[ "$issue" == *"Ubuntu"*"11.10"* ]] || [[ "$issue" == *"Ubuntu"*"12."* ]]
	then
	    if [[ "$(gsettings get org.gnome.desktop.background picture-uri)" == "'file:///$line'" ]]
	    then
		gsettings set org.gnome.desktop.background color-shading-type "solid"
                gsettings set org.gnome.desktop.background draw-background "true"
                gsettings set org.gnome.desktop.background picture-opacity "100"
                gsettings set org.gnome.desktop.background picture-options "zoom"
                gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/warty-final-ubuntu.png"
                gsettings set org.gnome.desktop.background primary-color "#cdab07740000"
                gsettings set org.gnome.desktop.background secondary-color "#2c2c00001e1e"
	    fi
	else
	    if [[ "$(gconftool --get /desktop/gnome/background/picture_filename)" == "$line" ]]
	    then
		gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
		gconftool-2 -t bool -s /desktop/gnome/background/draw_background "true"
		if [[ "$issue" == *"Debian"* ]]
		then
		    gconftool-2 -t string -s /desktop/gnome/background/picture_filename "/usr/share/images/desktop-base/desktop-background"
		else
		    gconftool-2 -t string -s /desktop/gnome/background/picture_filename "/usr/share/backgrounds/warty-final-ubuntu.png"
		fi
		gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
		gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
		gconftool-2 -t string -s /desktop/gnome/background/primary_color "#cdab07740000"
		gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#2c2c00001e1e"
		break
	    fi
	fi
    done <"$localdir"/.installed
fi

set +e
chmod -Rf u+rw "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
rm -rf "$localdir"/* "$localdir"/.[!.]* "$localdir"/...*
set -e
