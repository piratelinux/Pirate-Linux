#!/bin/bash

set -e

source /etc/profile
cd

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

mkdir -p /etc/portage/gpg
chmod 0700 /etc/portage/gpg
gpg --homedir /etc/portage/gpg --import /root/tmp/snapshot.asc
echo 'FEATURES="webrsync-gpg"' >> /etc/portage/make.conf
echo 'PORTAGE_GPG_DIR="/etc/portage/gpg"' >> /etc/portage/make.conf

cp /root/tmp/cupsd.conf /etc/cups/

for x in lp cdrom video cdrw usb lpadmin plugdev; do gpasswd -a guest $x ; done

#cd /root/tmp/etc/xdg/leafpad
#leafpad_ver=$(equery list -F '$version' leafpad)
#sed '1s/.*/'"$leafpad_ver"'/' <leafpadrc >leafpadrc_tmp
#mv leafpadrc_tmp leafpadrc

cd
cp -r /root/tmp/etc/xdg/* /etc/xdg/
cp /root/tmp/mime/mimeapps.list /usr/share/applications/

sed 's/\([*]lock[:][[:space:]]\+\)[[:alnum:]]\+/\1False/' </usr/share/X11/app-defaults/XScreenSaver | sed 's/\([*]dpmsQuickoffEnabled[:][[:space:]]\+[[:alnum:]]\+\)/\1\n*dpmsQuickOff:\t\tTrue/' | sed 's/\([*]dpmsQuickOff[:][[:space:]]\+\)[[:alnum:]]\+/\1True/' | sed 's/\([*]mode[:][[:space:]]\+\)[[:alnum:]]\+/\1blank/' >/root/tmp/XScreenSaver
mv /root/tmp/XScreenSaver /usr/share/X11/app-defaults/XScreenSaver

cd /home/guest
cp /root/tmp/home/.xinitrc .
cp -r /root/tmp/home/opt .
echo 'if [ "$(tty)" == "/dev/tty1" ]' >> .bash_profile
echo 'then' >> .bash_profile
echo -e '\tstartx' >> .bash_profile
echo 'fi' >> .bash_profile
mkdir -p .local/share/applications
sed 's/.*Name[=].*/Name=Aurora\/Firefox/' </usr/share/applications/firefox.desktop >.local/share/applications/firefox.desktop
cd
chown -R guest:guest /home/guest
chmod o-rwx /home/guest
