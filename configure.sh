og#!/bin/bash

set -e

source /etc/profile
cd
#TODO check correct fstab
cp /root/tmp/fstab /etc/
cp /root/tmp/hostname /etc/conf.d/
cp /root/tmp/hosts /etc/hosts
#TODO set random root password maybe
passwd -d root
emerge -q syslog-ng
#eselect news read new --mbox
rc-update add syslog-ng default
cp /root/tmp/inittab /etc/
emerge -q dhcpcd
#emerge ppp
useradd -m -G users,audio -s /bin/bash guest
#TODO set user password maybe
