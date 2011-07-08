#!/bin/bash
HOME=$(echo ~)
arch=$(arch)
wget http://www.piratelinux.org/repo/tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz.asc
wget http://www.piratelinux.org/repo/tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz
gpg --verify tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz.asc tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz
tar -xzf tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz
cd
if [ ! -d .local ]
 then mkdir .local
fi
cd .local
if [ ! -d share ]
 then mkdir share
fi
cd share
if [ ! -d icons ]
 then mkdir icons
fi
cp $HOME/piratepack/tor-browser/tor-browser.png icons
if [ ! -d applications ]
 then mkdir applications
fi
cp $HOME/piratepack/tor-browser/tor-browser.desktop applications
echo "Exec=$HOME/piratepack/tor-browser/tor-browser_en-US/start-tor-browser" >> applications/tor-browser.desktop
cd
