#!/bin/bash

set -e

maindir="$1"

echo "proxyPort=8124" >> .polipo
echo "diskCacheRoot=\"\"" >> .polipo
echo "disableLocalInterface=true" >> .polipo
echo "dnsNameServer=66.206.229.62" >> .polipo

awk '{sub(/[$]maindir/,"'"$maindir"'"); print}' firefox-pm > firefox-pm_tmp
mv firefox-pm_tmp firefox-pm

cp ".polipo" "$maindir/share/firefox-mods/"

mkdir "$maindir"/share/firefox-mods_build

cp firefox-pm  "$maindir"/share/firefox-mods_build/
chmod a+x "$maindir"/share/firefox-mods_build/firefox-pm

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/firefox-pm ]
then
    ln -s "$maindir"/share/firefox-mods_build/firefox-pm "$maindir"/bin/firefox-pm
fi

echo "Exec=$maindir/bin/firefox-pm" >> firefox-pm.desktop
cp firefox-pm.desktop "$maindir/share/firefox-mods/"
cp firefox-pm.png "$maindir/share/firefox-mods/"
