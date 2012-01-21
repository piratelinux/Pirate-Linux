#!/bin/bash

set -e

basedir="/opt/piratepack"

set +e
rm -r "$basedir"
set -e

rm -f /usr/bin/piratepack
rm -f /usr/bin/piratepack-refresh

grep -v "$basedir" /etc/profile > /etc/profile_tmp
mv -f /etc/profile_tmp /etc/profile

rm -f /usr/share/icons/hicolor/16x16/apps/piratepack.png
rm -f /usr/share/icons/hicolor/22x22/apps/piratepack.png
rm -f /usr/share/icons/hicolor/32x32/apps/piratepack.png
rm -f /usr/share/icons/hicolor/48x48/apps/piratepack.png
rm -f /usr/share/icons/hicolor/64x64/apps/piratepack.png
rm -f /usr/share/icons/hicolor/128x128/apps/piratepack.png
