#!/bin/bash                                                                    

set -e

curdir="$(pwd)"
basedir="$1"
maindir="$2"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack

grep -v "$basedir" .bashrc > .bashrc_tmp
mv .bashrc_tmp .bashrc
