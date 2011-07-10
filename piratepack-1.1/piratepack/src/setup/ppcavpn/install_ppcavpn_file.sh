#!/bin/bash

chmod u+r ppcavpn.tar.gz

if [ -d ppcavpn  ]
then
    chmod u+rx remove_ppcavpn_file.sh
    ./remove_ppcavpn_file.sh
fi

tar -xzf ppcavpn.tar.gz
cd ppcavpn

curdir="$(pwd)"

keyfile=$(find *.key)
keyfilelen=${#keyfile}
keyfilelensub=$(($targetdirlen - 4))
clientid=${keyfile:0:$keyfilelensub}

num=1

while true
do

dirs=$(gconftool --all-dirs /system/networking/connections)

if [[ $dirs == *$num* ]]
then
    let num=num+1
    continue
fi

targetdir="/system/networking/connections/$num"

gconftool-2 --type string --set $targetdir/connection/id "PPCA VPN"
gconftool-2 --type string --set $targetdir/connection/name "connection"
gconftool-2 --type string --set $targetdir/connection/type "vpn"
gconftool-2 --type string --set $targetdir/connection/uuid "$(uuidgen)"

gconftool-2 --type list --list-type int --set $targetdir/ipv4/addresses "[]"
gconftool-2 --type list --list-type int --set $targetdir/ipv4/addresses "[]"
gconftool-2 --type string --set $targetdir/ipv4/method "auto"
gconftool-2 --type string --set $targetdir/ipv4/name "ipv4"
gconftool-2 --type list --list-type int --set $targetdir/ipv4/routes "[]"

gconftool-2 --type string --set $targetdir/vpn/ca "$curdir/ca.crt"
gconftool-2 --type string --set $targetdir/vpn/cert "$curdir/$clientid.crt"
gconftool-2 --type string --set $targetdir/vpn/comp-lzo "yes"
gconftool-2 --type string --set $targetdir/vpn/connection-type "tls"
gconftool-2 --type string --set $targetdir/vpn/key "$curdir/$clientid.key"
gconftool-2 --type string --set $targetdir/vpn/port "443"
gconftool-2 --type string --set $targetdir/vpn/proto-tcp "yes"
gconftool-2 --type string --set $targetdir/vpn/remote "vpn.ostra.ca"
gconftool-2 --type string --set $targetdir/vpn/service-type "org.freedesktop.NetworkManager.openvpn"

echo "$targetdir" >> .installed

break

done

cd ..
chmod -R a-w ppcavpn
