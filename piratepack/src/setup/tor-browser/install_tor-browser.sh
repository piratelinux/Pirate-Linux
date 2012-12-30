#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir" ]
then 

    tar -xzf polipo-1.0.4.1.tar.gz
    cd polipo-1.0.4.1
    cp ../polipo_Makefile Makefile
    set +e
    make PREFIX="$maindir"/share/polipo_build all
    make PREFIX="$maindir"/share/polipo_build install
    set -e
    cd ..
    rm -rf polipo-1.0.4.1

    tar -xzf openssl-1.0.1c.tar.gz
    cd openssl-1.0.1c
    ./config --prefix="$maindir"/share/ssl_build shared
    set +e
    make
    set -e
    make test
    set +e
    make install
    set -e
    cd ..
    rm -rf openssl-1.0.1c

    tar -xzf libevent-2.0.20-stable.tar.gz
    cd libevent-2.0.20-stable
    ./configure --prefix="$maindir"/share/event_build
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf libevent-2.0.20-stable

    tar -xzf tor-0.2.2.39.tar.gz
    cd tor-0.2.2.39
    ./configure --prefix="$maindir"/share/tor_build --with-openssl-dir="$maindir"/share/ssl_build --with-libevent-dir="$maindir"/share/event_build --enable-static-openssl --enable-static-libevent
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf tor-0.2.2.39

    tar -xzf vidalia-0.2.20.tar.gz
    cd vidalia-0.2.20
    mkdir build
    cd build
    set +e
    cmake ..
    make
    set -e
    mkdir "$maindir"/share/vidalia_build
    cp src/vidalia/vidalia "$maindir"/share/vidalia_build/
    cd ../..
    rm -rf vidalia-0.2.20
fi

set +e
chmod a+rx "$maindir"/share/polipo_build/bin/polipo
chmod a+rx "$maindir"/share/tor_build/bin/tor
chmod a+rx "$maindir"/share/vidalia_build/vidalia
set -e

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

echo "socksParentProxy = localhost:9050" > .polipo_tor
echo "diskCacheRoot=\"\"" >> .polipo_tor
echo "disableLocalInterface=true" >> .polipo_tor

cp ".polipo_tor" "$maindir/share/tor-browser/"

echo "TorExecutable=""$maindir"/bin/tor >> .vidalia/vidalia.conf

cp -r ".vidalia" "$maindir/share/tor-browser/"

awk '{sub(/[$]maindir/,"'"$maindir"'"); print}' tor-instance > tor-instance_tmp
mv tor-instance_tmp tor-instance

awk '{sub(/[$]maindir/,"'"$maindir"'"); print}' tor-browser > tor-browser_tmp
mv tor-browser_tmp tor-browser

awk '{sub(/[$]maindir/,"'"$maindir"'"); print}' tor-irc > tor-irc_tmp
mv tor-irc_tmp tor-irc

issue="$(cat /etc/issue)"

if [[ "$issue" != *"Ubuntu"*"11.10"* ]] && [[ "$issue" != *"Ubuntu"*"12."* ]]
then
    awk '{sub(/purple[.]tar[.]gz/,"'"purple_old.tar.gz"'"); print}' tor-irc > tor-irc_tmp
    mv tor-irc_tmp tor-irc
fi

mkdir "$maindir"/share/tor-browser_build

cp tor-browser  "$maindir"/share/tor-browser_build/
chmod a+x "$maindir"/share/tor-browser_build/tor-browser

cp tor-instance  "$maindir"/share/tor-browser_build/
chmod a+x "$maindir"/share/tor-browser_build/tor-instance

cp tor-irc  "$maindir"/share/tor-browser_build/
chmod a+x "$maindir"/share/tor-browser_build/tor-irc

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor-browser ]
then
    ln -s "$maindir"/share/tor-browser_build/tor-browser "$maindir"/bin/tor-browser
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor-instance ]
then
    ln -s "$maindir"/share/tor-browser_build/tor-instance "$maindir"/bin/tor-instance
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor-irc ]
then
    ln -s "$maindir"/share/tor-browser_build/tor-irc "$maindir"/bin/tor-irc
fi

mkdir jondo
mv jondofox_linux_en.tar.bz2 jondo/
cd jondo
tar -xjf jondofox_linux_en.tar.bz2
tar -czf profile.tar.gz profile
cp profile.tar.gz "$maindir"/share/tor-browser/

cd "$curdir"

echo "Exec=$maindir/bin/tor-browser" >> tor-browser.desktop
cp tor-browser.desktop "$maindir/share/tor-browser/"
cp tor-browser.png "$maindir/share/tor-browser/"

echo "Exec=$maindir/bin/tor-instance" >> tor-instance.desktop
cp tor-instance.desktop "$maindir/share/tor-browser/"
cp tor-instance.png "$maindir/share/tor-browser/"

echo "Exec=$maindir/bin/tor-irc" >> tor-irc.desktop
cp tor-irc.desktop "$maindir/share/tor-browser/"
cp tor-irc.png "$maindir/share/tor-browser/"
