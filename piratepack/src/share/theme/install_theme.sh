#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/theme

gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
gconftool-2 -t bool -s /desktop/gnome/background/draw_background "true"
gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$curdir/ship.jpg"
gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
gconftool-2 -t string -s /desktop/gnome/background/primary_color "#000000000000"
gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#000000000000"

echo "$curdir/ship.jpg" >> "$localdir"/.installed
