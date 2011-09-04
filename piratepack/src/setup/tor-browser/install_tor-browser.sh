#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir"/tor-browser ] && [ ! "$(ls -A $maindir/tor-browser)" ]
then 

    tar -xzf polipo-1.0.4.tar.gz
    cd polipo-1.0.4
    set +e
    make all
    set -e
    mkdir "$maindir"/tor-browser/polipo
    cp polipo "$maindir"/tor-browser/polipo/
    cd ..
    rm -rf polipo-1.0.4

    tar -xzf tor-0.2.1.30.tar.gz
    cd tor-0.2.1.30
    ./configure --prefix="$maindir"/tor-browser/tor
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf tor-0.2.1.30
    
    tar -xzf vidalia-0.2.12.tar.gz
    cd vidalia-0.2.12
    mkdir build
    cd build
    set +e
    cmake ..
    make
    set -e
    mkdir "$maindir"/tor-browser/vidalia
    cp src/vidalia/vidalia "$maindir"/tor-browser/vidalia/
    cd ../..
    rm -rf vidalia-0.2.12
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/polipo ]
then
    ln -s "$maindir"/tor-browser/polipo/polipo "$maindir"/bin/polipo
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor ]
then
    ln -s "$maindir"/tor-browser/tor/bin/tor "$maindir"/bin/tor
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/vidalia ]
then
    ln -s "$maindir"/tor-browser/vidalia/vidalia "$maindir"/bin/vidalia
fi

echo "socksParentProxy = localhost:9050" > .polipo
echo "diskCacheRoot=\"\"" >> .polipo
echo "disableLocalInterface=true" >> .polipo

cp ".polipo" "$maindir/share/tor-browser/"

echo "[General]" > .vidalia/vidalia.conf
echo "LanguageCode=en" >> .vidalia/vidalia.conf
echo 'InterfaceStyle=GTK+' >> .vidalia/vidalia.conf
echo 'ShowMainWindowAtStart=false' >> .vidalia/vidalia.conf
echo >> .vidalia/vidalia.conf
echo "[Tor]" >> .vidalia/vidalia.conf
echo TorExecutable="$maindir"/bin/tor >> .vidalia/vidalia.conf

cp -r ".vidalia" "$maindir/share/tor-browser/"

echo '#!/bin/bash' > tor-browser
echo >> tor-browser                      
echo 'maindir='"$maindir" >> tor-browser
echo 'cd' >> tor-browser
echo 'HOME="$(pwd)"' >> tor-browser
echo >> tor-browser
echo 'if [[ $(pidof polipo) == "" ]]' >> tor-browser
echo 'then' >> tor-browser
echo '$maindir/bin/polipo &' >> tor-browser
echo 'fi' >> tor-browser
echo >> tor-browser
echo 'if [[ $(pidof tor) == "" ]]' >> tor-browser
echo 'then' >> tor-browser
echo 'kill $(pidof vidalia)' >> tor-browser
echo '$maindir/bin/vidalia &' >> tor-browser
echo 'else' >> tor-browser
echo 'if [[ $(pidof vidalia) == "" ]]' >> tor-browser
echo 'then' >> tor-browser
echo 'kill $(pidof tor)' >> tor-browser
echo '$maindir/bin/vidalia &' >> tor-browser
echo 'fi' >> tor-browser
echo 'fi' >> tor-browser
echo >> tor-browser
echo 'pid=""' >> tor-browser
echo >> tor-browser
echo 'if [ -e "$HOME"/.piratepack/tor-browser/.purple ]' >> tor-browser
echo 'then' >> tor-browser
echo 'pidgin --config="$HOME"/.piratepack/tor-browser/.purple &' >> tor-browser
echo 'pid=$!' >> tor-browser
echo 'fi' >> tor-browser
echo >> tor-browser
echo 'firefox -P tor -no-remote' >> tor-browser
echo >> tor-browser
echo 'if [[ "$pid" != "" ]]' >> tor-browser
echo 'then' >> tor-browser
echo 'kill $pid' >> tor-browser
echo 'fi' >> tor-browser

cp tor-browser "$maindir/bin"
chmod a+x "$maindir/bin/tor-browser"

cp "$maindir"/share/tor-browser/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi .
unzip {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi -d {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}
cp -r {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}-mods/installer/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}/* {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}
cd {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}
zip -r {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi .
rm ../{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi
rm "$maindir"/share/tor-browser/{e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi
cp {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}.xpi "$maindir"/share/tor-browser/
cd ..
rm -r {e0204bd5-9d31-402b-a99d-a6aa8ffebdca}

cp "$maindir"/share/tor-browser/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi .
unzip {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi -d {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
cp -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/installer/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}/* {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
cd {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
zip -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi .
rm ../{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi
rm "$maindir"/share/tor-browser/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi
cp {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi "$maindir"/share/tor-browser/
cd ..
rm -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}
mkdir "$maindir"/share/tor-browser/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods
cp -r {d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/profile "$maindir"/share/tor-browser/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods

cd "$maindir"
cd ..
basedir="$(pwd)"

cd "$curdir"

echo "Exec=$maindir/bin/tor-browser" >> tor-browser.desktop
cp tor-browser.desktop "$maindir/share/tor-browser/"
cp tor-browser.png "$maindir/share/tor-browser/"
