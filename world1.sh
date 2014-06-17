#!/bin/bash

set -e

source /etc/profile
cd

echo ">=dev-libs/libxml2-2.9.1-r1 python" >> /etc/portage/package.use
emerge -q app-crypt/gnupg
env-update
source /etc/profile
gpg --import /root/tmp/public.key

piratepack_overlay="piratepack-testing" #later change to non testing
emerge -q layman
env-update
source /etc/profile
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf
mkdir /root/layman
cp /root/tmp/overlays/piratepack.xml /root/layman/piratepack.xml
awk '/^overlays[ ][ ]:[ ]http[:][/][/]www[.]gentoo[.]org[/]proj[/]en[/]overlays[/]repositories[.]xml/{print;print "\tfile:///root/layman/piratepack.xml";next}1' /etc/layman/layman.cfg > /root/tmp/layman.cfg
mv /root/tmp/layman.cfg /etc/layman/layman.cfg
cp -r /root/tmp/overlays/cache_* /var/lib/layman/
cp -r /root/tmp/overlays/"$piratepack_overlay" /var/lib/layman/
layman -a "$piratepack_overlay"
cd /var/lib/layman/piratepack-testing
cd app-misc/cwallet
gpg --verify Manifest
cd ../../
cd net-misc/piratepack-i2p
gpg --verify Manifest
cd ../../
cd sys-apps/piratepack
gpg --verify Manifest
cd ../../
cd xfce-extra/piratelinux-xfconf
gpg --verify Manifest

cp /root/tmp/world /var/lib/portage/
cp /root/tmp/package.accept_keywords /etc/portage/
cp /root/tmp/package.use /etc/portage/
cp /root/tmp/package.license /etc/portage/
emerge -1 -q openssh
env-update
source /etc/profile
emerge -p -q --update --deep --newuse @world
