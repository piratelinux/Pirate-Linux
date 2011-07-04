#!/bin/bash
HOME=$(echo ~)
arch=$(arch)
wget http://www.torproject.org/dist/torbrowser/linux/tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz
wget http://www.torproject.org/dist/torbrowser/linux/tor-browser-gnu-linux-$arch-1.1.11-dev-en-US.tar.gz
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
cp $HOME/piratepack/tor/tor.png icons
if [ ! -d applications ]
 then mkdir applications
fi
cp $HOME/piratepack/tor/tor.desktop applications
echo "Exec=$HOME/piratepack/tor/tor-browser_en-US/start-tor-browser" >> applications/tor.desktop
cd
#echo "export PATH=$HOME/piratepack/tor/tor_browser_en-US:\$PATH" >> .bashrc
