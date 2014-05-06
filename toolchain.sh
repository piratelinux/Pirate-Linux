#!/bin/bash

#TODO: set gcc version with gcc-config

set -e

source /etc/profile
cd
emerge -1q binutils
env-update
source /etc/profile
emerge -1q gcc
env-update
source /etc/profile
emerge -1q glibc
env-update
source /etc/profile
