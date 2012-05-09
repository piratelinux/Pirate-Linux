#!/bin/bash

curdir="$(pwd)"
cd ../..
maindir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/theme

issue="$(cat /etc/issue)"

curimage=""

if [[ "$issue" == *"Ubuntu"*"11.10"* ]] || [[ "$issue" == *"Ubuntu"*"12.04"* ]]
then

    gsettings set org.gnome.desktop.background color-shading-type "solid"
    gsettings set org.gnome.desktop.background draw-background "true"
    gsettings set org.gnome.desktop.background picture-opacity "100"
    gsettings set org.gnome.desktop.background picture-options "zoom"
    gsettings set org.gnome.desktop.background picture-uri "file:///$curdir/background.jpg"
    gsettings set org.gnome.desktop.background primary-color "#000000000000"
    gsettings set org.gnome.desktop.background secondary-color "#000000"
    
    curimage="$(gsettings get org.gnome.desktop.background picture-uri)"
    if [[ "$curimage" == "'file:///$curdir/background.jpg'" ]]
    then
	echo "$curdir/background.jpg" >> "$localdir"/.installed
    fi

else
    gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
    gconftool-2 -t bool -s /desktop/gnome/background/draw_background "true"
    gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$curdir/background.jpg"
    gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
    gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
    gconftool-2 -t string -s /desktop/gnome/background/primary_color "#000000000000"
    gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#000000000000"

    curimage="$(gconftool --get /desktop/gnome/background/picture_filename)"
    if [[ "$curimage" == "$curdir/background.jpg" ]]
    then
        echo "$curdir/background.jpg" >> "$localdir"/.installed
    fi

fi

cd

mkdir -p Pictures
cd Pictures
if [ ! -e pirate ]
then
    mkdir pirate
    cd "$maindir"/share/graphics/backgrounds
    while read -r line
    do
	ln -s "$maindir"/share/graphics/backgrounds/"$line" "$homedir"/Pictures/pirate/"$line"
    done < <(find * maxdepth 0 2>> /dev/null)
    echo "$homedir"/Pictures/pirate >> "$localdir"/.installed
fi
