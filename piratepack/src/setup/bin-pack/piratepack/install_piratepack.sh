#!/bin/bash

set -e

curdir="$(pwd)"
basedir="/opt/piratepack"

mkdir -p "$basedir"

if [ -e piratepack ]
then
    rm -rf piratepack
fi
tar -xzf piratepack.tar.gz
cd piratepack

version=""

while read line
do
    if [[ "$line" == "Version: "* ]]
    then
	version=${line:9}
	break
    fi
done <main/README

maindir="$basedir/ver-$version"

if [ -d "$maindir" ]
then
    rm -rf "$maindir"
fi

cp -r "$curdir"/piratepack/main "$maindir"

issue="$(cat /etc/issue)"
if [[ "$issue" == *"Ubuntu"*"11.10"* ]] || [[ "$issue" == *"Ubuntu"*"12.04"* ]]
then
    cd "$maindir"/bin
    awk '{sub(/purple[_]old[.]tar[.]gz/,"'"purple.tar.gz"'"); print}' tor-irc > tor-irc_tmp
    mv tor-irc_tmp tor-irc
fi

mkdir -p "$basedir"/bin
ln -sf "$maindir"/bin/piratepack "$basedir"/bin/piratepack-tmp
mv -Tf "$basedir"/bin/piratepack-tmp "$basedir"/bin/piratepack
ln -sf "$maindir"/bin/piratepack-refresh "$basedir"/bin/piratepack-refresh-tmp
mv -Tf "$basedir/bin/piratepack-refresh-tmp" "$basedir/bin/piratepack-refresh"

grep -v "$basedir" /etc/profile > /etc/profile_tmp
mv -f /etc/profile_tmp /etc/profile
echo export PATH=\"$basedir/bin\":\"\$PATH\" >> /etc/profile
echo "\"$basedir/bin/piratepack\"" --refresh >> /etc/profile
apt-key add "$curdir"/piratepack/setup/public.key
cp -f "$curdir"/piratepack/setup/pirate.list /etc/apt/sources.list.d/
cp -f "$curdir"/piratepack/setup/piratepack.desktop /etc/xdg/autostart/

cd "$curdir"

if [ -e piratepack ]
then
    rm -rf piratepack
fi

while read -r line
do
    if [[ "$line" != "$maindir" ]] && [[ "$line" == "$basedir"/"ver-"* ]]
    then
	busy="0"
	touch "$line"/.lock
	for pid in $(pidof piratepack)
	do
	    processpath="$(readlink -f /proc/$pid/exe)"
	    processdir="$(dirname $processpath)"
	    if [[ "$processdir" == "$line" ]]
	    then
		rm -f $line/.lock
		busy="1"
		break
	    fi
	done
	if [[ "$busy" == "0" ]]
	then
	    rm -rf "$line/bin"
	    rm -r "$line"
	fi
    fi
done < <(find "$basedir" -mindepth 1 -maxdepth 1 -type d)

ln -sf "$basedir/bin/piratepack" "/usr/bin/piratepack-tmp"
mv -Tf "/usr/bin/piratepack-tmp" "/usr/bin/piratepack"
ln -sf "$basedir/bin/piratepack-refresh" "/usr/bin/piratepack-refresh-tmp"
mv -Tf "/usr/bin/piratepack-refresh-tmp" "/usr/bin/piratepack-refresh"

cd "$maindir"/share/graphics

cp -f logo_16.png /usr/share/icons/hicolor/16x16/apps/piratepack.png
cp -f logo_22.png /usr/share/icons/hicolor/22x22/apps/piratepack.png
cp -f logo_32.png /usr/share/icons/hicolor/32x32/apps/piratepack.png
cp -f logo_48.png /usr/share/icons/hicolor/48x48/apps/piratepack.png
cp -f logo_64.png /usr/share/icons/hicolor/64x64/apps/piratepack.png
cp -f logo_128.png /usr/share/icons/hicolor/128x128/apps/piratepack.png
