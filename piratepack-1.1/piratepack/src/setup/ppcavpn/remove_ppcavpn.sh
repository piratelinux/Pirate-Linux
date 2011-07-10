#!/bin/bash
if [ -d ppcavpn ]
then
    chmod u+rx remove_ppcavpn_file.sh
    ./remove_ppcavpn_file.sh
fi
chmod -R u+rw *
rm -rf *
