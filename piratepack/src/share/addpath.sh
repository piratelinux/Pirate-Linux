#!/bin/bash                                                                    

set -e

curdir="$(pwd)"
basedir="$1"
maindir="$2"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack

cd "$homedir"

grep -v "$basedir" .bashrc > .bashrc_tmp
mv -f .bashrc_tmp .bashrc
echo export PATH=\"$maindir/bin\":\"\$PATH\" >> .bashrc
