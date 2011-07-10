#!/bin/bash
gconftool-2 -t string -s /desktop/gnome/background/color_shading_type "solid"
gconftool-2 -t bool -s /desktop/gnome/background/picture_filename "true"
gconftool-2 -t string -s /desktop/gnome/background/picture_filename "/usr/share/backgrounds/warty-final-ubuntu.png"
gconftool-2 -t int -s /desktop/gnome/background/picture_opacity "100"
gconftool-2 -t string -s /desktop/gnome/background/picture_options "zoom"
gconftool-2 -t string -s /desktop/gnome/background/primary_color "#cdab07740000"
gconftool-2 -t string -s /desktop/gnome/background/secondary_color "#2c2c00001e1e"
rm -rf *