#!/bin/bash

set -e

ver="1.4"
subver="1"

rm -rf ../deb/piratepack-"$ver"-"$subver"
mkdir ../deb/piratepack-"$ver"-"$subver"
tar -czf piratepack.tar.gz piratepack
cp piratepack.tar.gz ../deb/piratepack-"$ver"-"$subver"
cp install_piratepack.sh ../deb/piratepack-"$ver"-"$subver"
cp remove_piratepack.sh ../deb/piratepack-"$ver"-"$subver"
cp README ../deb/piratepack-"$ver"-"$subver"
#cp debuild ../deb/piratepack-"$ver"-"$subver"
cd ../deb
tar -czf piratepack-"$ver".tar.gz piratepack-"$ver"-"$subver"
cp piratepack-"$ver".tar.gz piratepack_"$ver".orig.tar.gz
rm -r piratepack-"$ver"-"$subver"
tar -xzf piratepack_"$ver".orig.tar.gz
cp -r ../git/debian piratepack-"$ver"-"$subver"
cd piratepack-"$ver"-"$subver"
debuild
cd ..
gpg --default-key "<akarmn@gmail.com>" -ab piratepack_"$ver"-"$subver"_all.deb
cp piratepack_"$ver"-"$subver"_all.deb ../repo/deb/pool/testing/main/
cp piratepack_"$ver"-"$subver"_all.deb.asc ../repo/deb/pool/testing/main/
