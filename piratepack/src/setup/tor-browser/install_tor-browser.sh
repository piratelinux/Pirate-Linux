#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir" ]
then 

    tar -xzf polipo-1.0.4.tar.gz
    cd polipo-1.0.4
    cp ../polipo_Makefile Makefile
    set +e
    make PREFIX="$maindir"/share/polipo_build all
    make PREFIX="$maindir"/share/polipo_build install
    set -e
    cd ..
    rm -rf polipo-1.0.4

    tar -xzf openssl-1.0.0f.tar.gz
    cd openssl-1.0.0f
    ./config --prefix="$maindir"/share/ssl_build shared
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf openssl-1.0.0f

    tar -xzf libevent-2.0.16-stable.tar.gz
    cd libevent-2.0.16-stable
    ./configure --prefix="$maindir"/share/event_build
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf libevent-2.0.16-stable

    tar -xzf tor-0.2.2.35.tar.gz
    cd tor-0.2.2.35
    ./configure --prefix="$maindir"/share/tor_build --with-openssl-dir="$maindir"/share/ssl_build --with-libevent-dir="$maindir"/share/event_build --enable-static-openssl --enable-static-libevent
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf tor-0.2.2.35

    tar -xzf vidalia-0.2.15.tar.gz
    cd vidalia-0.2.15
    mkdir build
    cd build
    set +e
    cmake ..
    make
    set -e
    mkdir "$maindir"/share/vidalia_build
    cp src/vidalia/vidalia "$maindir"/share/vidalia_build/
    cd ../..
    rm -rf vidalia-0.2.15
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/polipo ]
then
    ln -s "$maindir"/share/polipo_build/bin/polipo "$maindir"/bin/polipo
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor ]
then
    ln -s "$maindir"/share/tor_build/bin/tor "$maindir"/bin/tor
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/vidalia ]
then
    ln -s "$maindir"/share/vidalia_build/vidalia "$maindir"/bin/vidalia
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

mkdir "$maindir"/share/tor-browser_build
cp tor-browser  "$maindir"/share/tor-browser_build/
chmod a+x "$maindir"/share/tor-browser_build/tor-browser

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor-browser ]
then
    ln -s "$maindir"/share/tor-browser_build/tor-browser "$maindir"/bin/tor-browser
fi

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

cd "$curdir"

echo "Exec=$maindir/bin/tor-browser" >> tor-browser.desktop
cp tor-browser.desktop "$maindir/share/tor-browser/"
cp tor-browser.png "$maindir/share/tor-browser/"
