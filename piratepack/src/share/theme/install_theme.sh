#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/theme

issue=$(cat /etc/issue)

if [[ "$issue" == *"Ubuntu 11.10"* ]]
then

    while [[ $(pidof vidalia) == "" ]]
    do
	sleep 1
    done

    gsettings set org.gnome.desktop.background color-shading-type "solid"
    gsettings set org.gnome.desktop.background draw-background "true"
    gsettings set org.gnome.desktop.background picture-opacity "100"
    gsettings set org.gnome.desktop.background picture-options "zoom"
    gsettings set org.gnome.desktop.background picture-uri "file:///$curdir/tpb.png"
    gsettings set org.gnome.desktop.background primary-color "#000000000000"
    gsettings set org.gnome.desktop.background secondary-color "#000000"
else
    gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
    gconftool-2 -t bool -s /desktop/gnome/background/draw_background "true"
    gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$curdir/tpb.png"
    gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
    gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
    gconftool-2 -t string -s /desktop/gnome/background/primary_color "#000000000000"
    gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#000000000000"
fi

echo "$curdir/tpb.png" >> "$localdir"/.installed
