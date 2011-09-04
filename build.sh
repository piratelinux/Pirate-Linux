#!/bin/bash

set -e

ver="1.2"
subver="14"

tar -czf piratepack.tar.gz piratepack
cp piratepack.tar.gz ../deb/piratepack-"$ver"-"$subver"
cp install_piratepack.sh ../deb/piratepack-"$ver"-"$subver"
cp remove_piratepack.sh ../deb/piratepack-"$ver"-"$subver"
cp README ../deb/piratepack-"$ver"-"$subver"
cd ../deb/piratepack-"$ver"-"$subver"
rm -r debian
cd ..
tar -czf piratepack-"$ver".tar.gz piratepack-"$ver"-"$subver"
cp piratepack-"$ver".tar.gz piratepack_"$ver".orig.tar.gz
rm -r piratepack-"$ver"-"$subver"
tar -xzf piratepack_"$ver".orig.tar.gz
tar -xzf piratepack_"$ver"-"$subver".debian.tar.gz
mv debian piratepack-"$ver"-"$subver"
cd piratepack-"$ver"-"$subver"
debuild
cd ..
gpg --default-key "<akarmn@gmail.com>" -ab piratepack_"$ver"-"$subver"_all.deb
