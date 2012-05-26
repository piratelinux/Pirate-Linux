#!/bin/bash

set -e

curdir="$(pwd)"
maindir="$1"

if [ -d "$maindir" ]
then 

    export JAVA_HOME=$(readlink -f "$(which javac)" | sed "s:/bin/javac::")

    tar -xzf JRobinLite-1.5.9.1.tar.gz
    cd JRobinLite-1.5.9.1
    rm -f lib/*.jar
    cd ant
    ant
    cd ..
    cp lib/jrobin-1.5.9.1.jar ../i2p-patch/apps/jrobin/
    cd ..
    rm -rf JRobinLite-1.5.9.1

    tar -xzf wrapper_3.5.14_src.tar.gz
    cp -r wrapper-patch/* wrapper_3.5.14_src/
    cd wrapper_3.5.14_src
    bits=32
    if [[ "$(arch)" == "x86_64" ]]
    then
	bits="64"
	echo "BITS=64"
    fi
    ant -Dbits="$bits"
    cp lib/wrapper.jar ../i2p-patch/installer/lib/wrapper/all/

    OS_ARCH="$(uname -m)"

    if [[ "$OS_ARCH" == *"armv7"* ]]; then
	wrapperpath="linux-armv7"
    elif [[ "$OS_ARCH" == *"arm"* ]]; then
	wrapperpath="linux-armv5"
    elif [[ "$OS_ARCH" == *"ppc"* ]]; then
	wrapperpath="linux-ppc"
    elif [[ "$OS_ARCH" == *"x86_64"* ]]; then
	wrapperpath="linux64"
    else
	wrapperpath="linux"
    fi

    mkdir -p ../i2p-patch/installer/lib/wrapper/"$wrapperpath"
    strip --strip-unneeded bin/wrapper lib/libwrapper.so
    chmod 644 bin/wrapper lib/libwrapper.so
    cp lib/libwrapper.so ../i2p-patch/installer/lib/wrapper/"$wrapperpath"/
    cp bin/wrapper ../i2p-patch/installer/lib/wrapper/"$wrapperpath"/i2psvc
    cd ..
    rm -rf wrapper_3.5.14_src

    if [ -e /opt/piratepack/patch/i2p-browser ]
    then
	cp -r /opt/piratepack/patch/i2p-browser/* .
    fi

    tar -xjf i2psource_0.9-mod.tar.bz2
    cd i2p-0.9
    cp -r ../i2p-patch/* .
    cd core/c/jbigi
    ./build.sh dynamic
    cp lib/libjbigi.so ../../../installer/lib/jbigi/
    cd ../jcpuid
    ./build.sh
    cp lib/freenet/support/CPUInformation/libjcpuid*.so ../../../installer/lib/jbigi/
    cd ../../../
    ant pkg
    INSTALL_PATH="$maindir"/share/i2p-browser_build
    cp -r pkg-temp "$INSTALL_PATH"
    cd "$INSTALL_PATH"
    awk '{sub(/[%]INSTALL[_]PATH/,"'"$INSTALL_PATH"'"); print}' eepget > eepget_tmp
    mv eepget_tmp eepget
    awk '{sub(/[%]INSTALL[_]PATH/,"'"$INSTALL_PATH"'"); print}' i2prouter > i2prouter_tmp
    mv i2prouter_tmp i2prouter
    awk '{sub(/[%]INSTALL[_]PATH/,"'"$INSTALL_PATH"'"); print}' runplain.sh > runplain.sh_tmp
    mv runplain.sh_tmp runplain.sh
    awk '{sub(/[$]INSTALL[_]PATH/,"'"$INSTALL_PATH"'"); print}' wrapper.config > wrapper.config_tmp
    mv wrapper.config_tmp wrapper.config
    awk '{sub(/[%]SYSTEM[_]java[_]io[_]tmpdir/,"'"/tmp"'"); print}' i2prouter > i2prouter_tmp
    mv i2prouter_tmp i2prouter
    awk '{sub(/[%]SYSTEM[_]java[_]io[_]tmpdir/,"'"/tmp"'"); print}' runplain.sh > runplain.sh_tmp
    mv runplain.sh_tmp runplain.sh
    awk '{sub(/[$]SYSTEM[_]java[_]io[_]tmpdir/,"'"/tmp"'"); print}' wrapper.config > wrapper.config_tmp
    mv wrapper.config_tmp wrapper.config
    chmod u+rx postinstall.sh
    ./postinstall.sh "$INSTALL_PATH"
    echo '#!/bin/bash' > i2p-browser
    echo "$maindir"/bin/'i2prouter start' >> i2p-browser
    echo 'firefox -P i2p -no-remote' >> i2p-browser
    echo 'killall i2psvc' >> i2p-browser
    chmod a+rx i2p-browser
    cd "$curdir"
    rm -rf i2p-0.9
fi

awk '{sub(/[$]maindir/,"'"$maindir"'"); print}' i2p-irc > i2p-irc_tmp
mv i2p-irc_tmp i2p-irc

cp i2p-irc  "$maindir"/share/i2p-browser_build/
chmod a+x "$maindir"/share/i2p-browser_build/i2p-irc

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/eepget ]
then
    ln -s "$maindir"/share/i2p-browser_build/eepget "$maindir"/bin/eepget
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/i2prouter ]
then
    ln -s "$maindir"/share/i2p-browser_build/i2prouter "$maindir"/bin/i2prouter
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/i2psvc ]
then
    ln -s "$maindir"/share/i2p-browser_build/i2psvc "$maindir"/bin/i2psvc
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/i2p-browser ]
then
    ln -s "$maindir"/share/i2p-browser_build/i2p-browser "$maindir"/bin/i2p-browser
fi

if [ -d "$maindir"/bin ] && [ ! -e "$maindir"/bin/i2p-irc ]
then
    ln -s "$maindir"/share/i2p-browser_build/i2p-irc "$maindir"/bin/i2p-irc
fi

echo "Exec=$maindir/bin/i2p-browser" >> i2p-browser.desktop
cp i2p-browser.desktop "$maindir/share/i2p-browser/"
cp i2p-browser.png "$maindir/share/i2p-browser/"

echo "Exec=$maindir/bin/i2p-irc" >> i2p-irc.desktop
cp i2p-irc.desktop "$maindir/share/i2p-browser/"
cp i2p-irc.png "$maindir/share/i2p-browser/"
