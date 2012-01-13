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
versionfull="$version"

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
    versionfull="$version"_"$maxnumadd"

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
    mkdir bin-pack
    mkdir src

    cd $curdir/piratepack

    cp README "$maindir"

    cp -r src/share "$maindir/"

    set +e
    ./configure
    make
    set -e
    cp src/piratepack "$maindir/bin"
    
    cd src/setup

    cd firefox-mods
    ./install_firefox-mods.sh "$maindir"

    cd ..

    cd tor-browser
    ./install_tor-browser.sh "$maindir"

    cd ..

    cd bitcoin
    ./install_bitcoin.sh "$maindir"

    cd ..

    cd "$curdir"
    cp piratepack.tar.gz "$maindir/src"
    cp install_piratepack.sh "$maindir/src"
    cp remove_piratepack.sh "$maindir/src"

    mkdir -p "$basedir"/bin
    ln -sf "$maindir"/bin/piratepack "$basedir"/bin/piratepack-tmp
    mv -Tf "$basedir/bin/piratepack-tmp" "$basedir/bin/piratepack"
    ln -sf "$maindir/bin-pack" "$basedir/bin-pack_tmp"
    mv -Tf "$basedir/bin-pack_tmp" "$basedir/bin-pack"

fi

if [[ "$continue" == "1" ]]
then

    cp -r "$maindir"/share "$curdir"/piratepack/src/setup/bin-pack/piratepack/piratepack/main
    cp -r "$maindir"/bin "$curdir"/piratepack/src/setup/bin-pack/piratepack/piratepack/main    

    cd "$curdir"/piratepack/src/setup/bin-pack/piratepack/piratepack/main
    echo "Version: $versionfull" > README
    cd ../..
    tar -czf piratepack.tar.gz piratepack
    rm -r piratepack
    cd ..
    mv piratepack piratepack-"$version"bin
    i=0
    n=${#version}
    subver=""
    while (( i < $n ))
    do
	char=${version:$i:1}
	if [[ "$char" == "-" ]]
	then
	    subver=${version:0:$i}
	    break
	fi
	let i=i+1
    done
    tar -czf piratepack-"$subver".tar.gz piratepack-"$version"bin
    rm -r piratepack-"$version"bin
    cp piratepack-"$subver".tar.gz piratepack_"$subver".orig.tar.gz
    tar -xzf piratepack_"$subver".orig.tar.gz
    mv debian piratepack-"$version"bin
    cd piratepack-"$version"bin
    dpkg-buildpackage -us -uc
    cd ..
    mv *.deb "$maindir"/bin-pack
    
    apt-key add "$curdir"/piratepack/src/setup/public.key
    cp "$curdir"/piratepack/src/setup/pirate.list /etc/apt/sources.list.d/
    
    cd "$curdir"
    
fi

if [[ "$continue" == "1" ]]
then
    if [ -e piratepack ]
    then
	rm -rf piratepack
    fi

    grep -v "$basedir" /etc/profile > /etc/profile_tmp
    mv /etc/profile_tmp /etc/profile
    echo export PATH=\"$basedir/bin\":\"\$PATH\" >> /etc/profile
    echo "\"$basedir/bin/piratepack\"" --refresh >> /etc/profile
fi

#cleanup other versions

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

if [[ "$continue" == "1" ]]
then

    ln -sf "$basedir/bin/piratepack" "/usr/bin/piratepack-tmp"
    mv -Tf "/usr/bin/piratepack-tmp" "/usr/bin/piratepack"

fi
