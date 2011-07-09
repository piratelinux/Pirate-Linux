#!/bin/bash
HOME=$(echo ~)
curdir=$(pwd)

#wget http://www.piratelinux.org/repo/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.xpi
#wget http://www.piratelinux.org/repo/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}.json
#wget http://www.piratelinux.org/repo/MafiaaFire@mafiaafire.com.xpi
#wget http://www.piratelinux.org/repo/MafiaaFire@mafiaafire.com.json
#wget http://www.piratelinux.org/repo/https-everywhere@eff.org.xpi
#wget http://www.piratelinux.org/repo/https-everywhere@eff.org.json
chmod u+rw https-everywhere@eff.org.xpi
unzip https-everywhere@eff.org.xpi -d https-everywhere@eff.org
#wget http://www.piratelinux.org/repo/firefox@ghostery.com.xpi
#wget http://www.piratelinux.org/repo/firefox@ghostery.com.json
chmod u+rw firefox@ghostery.com.xpi
unzip firefox@ghostery.com.xpi -d firefox@ghostery.com
#wget http://www.piratelinux.org/repo/john@velvetcache.org.xpi
#wget http://www.piratelinux.org/repo/john@velvetcache.org.json

cd
cd .mozilla/firefox/*.default
if [ ! -d extensions ]
 then mkdir extensions
fi
chmod u+rw extensions
cd extensions
extdir=$(pwd)
mkdir staged
chmod u+rw staged
cd $curdir
find *.xpi | while read line; do
    if [ ! -e $extdir/$line ]
    then
        linelen=${#line}
        linelensub=$(($linelen - 4))
	if [ -d ${line:0:$linelensub} ]
	then
	    cp -r ${line:0:$linelensub} $extdir/staged
	    echo $extdir/${line:0:$linelensub} >> .installed
	else
	    cp $line $extdir/staged
	    echo $extdir/$line >> .installed
	fi
	cp ${line:0:$linelensub}.json $extdir/staged
    fi
done
