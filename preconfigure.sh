#!/bin/bash

set -e

portagever="$1"

tar xjpf /root/tmp/portage-"$portagever".tar.bz2 -C /usr/
cp -r /root/tmp/distfiles /usr/portage/
eselect profile list
echo "UTC" > /etc/timezone
emerge --config sys-libs/timezone-data
awk '{sub(/[#]en[_]US/,"'"en_US"'"); print}' /etc/locale.gen > /root/tmp/locale.gen
mv /root/tmp/locale.gen /etc/locale.gen
locale-gen
eselect locale set "en_US.utf8"
env-update
source /etc/profile
