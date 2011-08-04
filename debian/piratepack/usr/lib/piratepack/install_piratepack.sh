#!/bin/bash

set -e

curdir="$(pwd)"
basedir="$1" #defaults to /opt/piratepack

continue="1"

if [[ "$basedir" == "" ]]
then
    basedir="/opt/piratepack"
fi

if [[ "$basedir" == *"/" ]]
then
    basedirlen=${#basedir}
    basedirlensub=$(($basedirlen - 1))
    basedir="${basedir:0:$basedirlensub}"
fi

if [[ "$basedir" == *"/" ]]
then
    echo "incorrect syntax for base directory"
    continue="0"
fi

if [[ "$continue" == "1" ]]
then
    if [ -e piratepack ]
    then
	rm -rf piratepack
    fi
    tar -xzf piratepack.tar.gz
    cd piratepack
fi

version=""

if [[ "$continue" == "1" ]]
then
    while read line
    do
	if [[ "$line" == "Version: "* ]]
	then
	    version=${line:9}
	    break
	fi
    done <README
fi

maindir=""

if [[ "$continue" == "1" ]]
then

    if [ ! -d "$basedir" ]
    then
	if [ ! -d $(dirname "$basedir") ]
	then
	    echo "parent directory of specified base directory does not exist"
            continue="0"
	else
	    mkdir "$basedir"
	fi
    fi


    maindir="$basedir/ver-$version"
	
    maxnum="0"
    maindirlen=${#maindir}
    maindirlenadd=$(($maindirlen + 1))
    
    while read -r line
    do
	ext=${line:$maindirlenadd}
	if [[ "$ext" =~ ^[0-9]+$ ]] ; then
	    if [ "$ext" -gt "$maxnum" ]
	    then
		maxnum="$ext"
	    fi
	fi
    done < <(find "$maindir"_* -maxdepth 0)
    
    maxnumadd=$(($maxnum + 1))
    maindir="$maindir"_"$maxnumadd"
    
    if [ ! -d "$maindir" ]
    then
	mkdir "$maindir"
    fi
    
    continue="1"

fi

if [[ "$continue" == "1" ]]
then
    cd "$maindir"
    mkdir bin
    mkdir share
    mkdir src
    mkdir tor-browser

    cd $curdir/piratepack
    cp -r src/share/* "$maindir/share"
    
    ./configure
    make
    cp src/piratepack "$maindir/bin"
    
    cd src/setup

    cd firefox-mods
    ./install_firefox-mods.sh "$maindir"

    cd ..

    cd tor-browser
    ./install_tor-browser.sh "$maindir"

    cd ..

    cd "$curdir"
    cp piratepack.tar.gz "$maindir/src"

    ln -s "$maindir/bin" "$basedir/bin_tmp"

    mv -Tf "$basedir/bin_tmp" "$basedir/bin"

fi

cd "$curdir"

if [[ "$continue" == "1" ]]
then
    if [ -e piratepack ]
    then
	rm -r piratepack
    fi

    file=$(</etc/profile)
    echo "$file" | {
	while read line; do
	    if [[ "$line" != *"$basedir"* ]]; then
		echo "$line"
	    fi
	done
    } > /etc/profile

    echo "\"$basedir/bin/piratepack\"" --refresh >> /etc/profile
fi

#cleanup other versions

if [[ "$continue" == "1" ]]
then
    while read -r line
    do
	if [[ "$line" != "$maindir" ]]
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
		rm -r "$line/bin"
		rm -r "$line"
	    fi
	fi
    done < <(find "$basedir" -mindepth 1 -maxdepth 1 -type d)
    
fi

ln -s "$basedir/bin/piratepack" "/usr/bin/piratepack-tmp"
mv -Tf "/usr/bin/piratepack-tmp" "/usr/bin/piratepack"
