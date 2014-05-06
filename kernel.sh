#!/bin/bash

set -e

kernelver="$1"

source /etc/profile
cd
emerge -1 -q hardened-sources:"$kernelver"
cd /usr/src/linux
cp /root/tmp/kernel_config .config
make > /root/logs/kernel_make.log
make modules_install > /root/logs/kernel_modules_install.log
env-update
source /etc/profile
