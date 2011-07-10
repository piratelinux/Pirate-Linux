#!/bin/bash
chmod u+r $1
tar -xzf $1
targetdir=$(find *_pirate -maxdepth 0)
targetdirlen=${#targetdir}
targetdirlensub=$(($targetdirlen - 7))
targetname=${targetdir:0:$targetdirlensub}
cd $targetdir
#todo:verify signature
cp $targetname.tar.gz ../../$targetname
cp $targetname.tar.gz.asc ../../$targetname
cd ../..
cd $targetname
chmod u+rx "install"_"$targetname"_"file.sh"
"./install"_"$targetname"_"file.sh"
cd ..
chmod -R u+rw tmp
rm -rf tmp
  