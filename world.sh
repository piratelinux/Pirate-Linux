#!/bin/bash

set -e

source /etc/profile
cd

echo ">=dev-libs/libxml2-2.9.1-r1 python" >> /etc/portage/package.use
emerge -q layman
env-update
source /etc/profile
echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf
mkdir /root/layman
cp /root/tmp/piratepack.xml /root/layman/piratepack.xml
awk '/^overlays[ ][ ]:[ ]http[:][/][/]www[.]gentoo[.]org[/]proj[/]en[/]overlays[/]repositories[.]xml/{print;print "\tfile:///root/layman/piratepack.xml";next}1' /etc/layman/layman.cfg > /root/tmp/layman.cfg
mv /root/tmp/layman.cfg /etc/layman/layman.cfg
layman -L
layman -a piratepack-testing
rm -r /var/lib/layman/piratepack-testing
cp -r /root/tmp/piratepack-testing /var/lib/layman/

cp /root/tmp/world /var/lib/portage/
cp /root/tmp/package.accept_keywords /etc/portage/
cp /root/tmp/package.use /etc/portage/
cp /root/tmp/package.license /etc/portage/
emerge -1 -q openssh
env-update
source /etc/profile
emerge -q --update --deep --newuse @world
env-update
source /etc/profile
emerge -q --oneshot libtool
env-update
source /etc/profile
emerge --with-bdeps=n --depclean
revdep-rebuild
env-update
source /etc/profile
#update config files?
cp /root/tmp/locale.nopurge /etc/
localepurge > /root/logs/localepurge.log
makewhatis -u
rm -r /usr/src/linux*
rm -r /usr/portage

rc-update add NetworkManager default
rc-update add alsasound boot
rc-update add consolekit default
rc-update add cupsd default
rc-update add lvm boot
rc-update add ntpd default
rc-update add udev sysinit
rc-update add udev-mount sysinit #check
rc-update add kmod-static-nodes sysinit #check
rc-update add net.lo boot #check
rc-update add dbus default #maybe unnecessary
rc-update delete hwclock boot #check

echo "server 127.127.1.0" >> /etc/ntp.conf
echo "fudge  127.127.1.0 stratum 10" >> /etc/ntp.conf
echo "disable monitor" >> /etc/ntp.conf

echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

mkdir -p /etc/portage/gpg
chmod 0700 /etc/portage/gpg
gpg --homedir /etc/portage/gpg --import /root/tmp/snapshot.asc
echo 'FEATURES="webrsync-gpg"' >> /etc/portage/make.conf
echo 'PORTAGE_GPG_DIR="/etc/portage/gpg"' >> /etc/portage/make.conf

for x in lp cdrom video cdrw usb lpadmin plugdev; do gpasswd -a guest $x ; done
cd /home/guest
cp -r /root/tmp/home/.config .
cp /root/tmp/home/.xscreensaver .
cp /root/tmp/home/.xinitrc .
echo 'if [ "$(tty)" == "/dev/tty1" ]' >> .bash_profile
echo 'then' >> .bash_profile
echo -e '\tstartx' >> .bash_profile
echo 'fi' >> .bash_profile
mkdir -p .local/share/applications
sed 's/.*Name[=].*/Name=Aurora\/Firefox/' </usr/share/applications/firefox.desktop >.local/share/applications/firefox.desktop
cd
chown -R guest:guest /home/guest
chmod o-rwx /home/guest
