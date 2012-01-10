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
    make install
    set -e
    cd ..
    rm -rf polipo-1.0.4
    cd /usr/share
    mkdir -p "$maindir"/tmp/polipo_build/usr/share
    cp -r polipo "$maindir"/tmp/polipo_build/usr/share/
    cd ../local/man/man1
    mkdir -p "$maindir"/tmp/polipo_build/usr/local/share/man/man1
    cp polipo.1 "$maindir"/tmp/polipo_build/usr/local/share/man/man1/
    cd ../../bin
    mkdir -p "$maindir"/tmp/polipo_build/usr/local/bin
    cp polipo "$maindir"/tmp/polipo_build/usr/local/bin/
    cd ../info
    mkdir -p "$maindir"/tmp/polipo_build/usr/local/info
    cp polipo.info "$maindir"/tmp/polipo_build/usr/local/info/
    if [ -e dir ]
    then
	cp dir "$maindir"/tmp/polipo_build/usr/local/info/
    fi
    cd "$curdir"

    tar -xzf openssl-1.0.0f.tar.gz
    cd openssl-1.0.0f
    ./config --prefix=/usr/local shared
    make
    make install
    cd ..
    rm -rf openssl-1.0.0f

    tar -xzf libevent-2.0.16-stable.tar.gz
    cd libevent-2.0.16-stable
    ./configure --prefix=/usr/local
    make
    make install
    cd ..
    rm -rf libevent-2.0.16-stable

    tar -xzf tor-0.2.2.35.tar.gz
    cd tor-0.2.2.35
    ./configure --prefix=/usr/local --with-openssl-dir=/usr/local/lib --with-libevent-dir=/usr/local/lib --enable-static-openssl --enable-static-libevent
    set +e
    make
    make install
    set -e
    cd ..
    rm -rf tor-0.2.2.35
    cd /usr/local/etc
    mkdir -p "$maindir"/tmp/tor_build/usr/local/etc
    cp -r tor "$maindir"/tmp/tor_build/usr/local/etc/
    cd ../share/doc
    mkdir -p "$maindir"/tmp/tor_build/usr/local/share/doc
    cp -r tor "$maindir"/tmp/tor_build/usr/local/share/doc/
    cd ../man/man1
    mkdir -p "$maindir"/tmp/tor_build/usr/local/share/man/man1
    cp tor-resolve.1 "$maindir"/tmp/tor_build/usr/local/share/man/man1/
    cp torify.1 "$maindir"/tmp/tor_build/usr/local/share/man/man1/
    cp tor-gencert.1 "$maindir"/tmp/tor_build/usr/local/share/man/man1/
    cp tor.1 "$maindir"/tmp/tor_build/usr/local/share/man/man1/
    cd ../..
    cp -r tor "$maindir"/tmp/tor_build/usr/local/share/
    cd ../bin
    mkdir -p "$maindir"/tmp/tor_build/usr/local/bin
    cp tor "$maindir"/tmp/tor_build/usr/local/bin/
    cp tor-resolve "$maindir"/tmp/tor_build/usr/local/bin/
    cp tor-gencert "$maindir"/tmp/tor_build/usr/local/bin/
    cp torify "$maindir"/tmp/tor_build/usr/local/bin/
    cd "$curdir"

    tar -xzf vidalia-0.2.15.tar.gz
    cd vidalia-0.2.15
    mkdir build
    cd build
    set +e
    cmake ..
    make
    set -e
    mkdir "$maindir"/tor-browser/vidalia
    cp src/vidalia/vidalia "$maindir"/tor-browser/vidalia/
    cd ../..
    rm -rf vidalia-0.2.15
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/polipo ]
then
    ln -s /usr/local/bin/polipo "$maindir"/bin/polipo
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor ]
then
    ln -s /usr/local/bin/tor "$maindir"/bin/tor
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

if [ -d "$maindir"/tor-browser ]
then
    cp tor-browser  "$maindir"/tor-browser/
    chmod a+x "$maindir"/tor-browser/tor-browser
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/tor-browser ]
then
    ln -s "$maindir"/tor-browser/tor-browser "$maindir"/bin/tor-browser
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
