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
    rm -r "$maindir"
fi

cp -r "$curdir"/piratepack/main "$maindir"

mkdir -p "$basedir"/bin
ln -sf "$maindir"/bin/piratepack "$basedir"/bin/piratepack-tmp
mv -Tf "$basedir"/bin/piratepack-tmp "$basedir"/bin/piratepack

apt-key add "$curdir"/piratepack/setup/public.key
cp "$curdir"/piratepack/setup/pirate.list /etc/apt/sources.list.d/

cd "$curdir"

if [ -e piratepack ]
then
    rm -r piratepack
fi

grep -v "$basedir" /etc/profile > /etc/profile_tmp
mv /etc/profile_tmp /etc/profile
echo export PATH=\"$basedir/bin\":\"\$PATH\" >> /etc/profile
echo "\"$basedir/bin/piratepack\"" --refresh >> /etc/profile

if [[ "$continue" == "1" ]]
then
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
		    rm $line/.lock
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
fi

ln -sf "$basedir/bin/piratepack" "/usr/bin/piratepack-tmp"
mv -Tf "/usr/bin/piratepack-tmp" "/usr/bin/piratepack"
