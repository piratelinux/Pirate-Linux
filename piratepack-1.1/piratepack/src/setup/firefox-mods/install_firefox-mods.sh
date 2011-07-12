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

fullversion=$(firefox -version)

version="4"
if [[ $fullversion == *"Mozilla Firefox 3"* ]]
then
    version="3"
fi

if [ -d .mozilla/firefox/*.default ]
then 
    cd .mozilla/firefox/*.default
    if [ ! -d extensions ]
    then
	mkdir extensions
    fi
    chmod u+rw extensions
    cd extensions
    extdir=$(pwd)
    if [[ $version != "3" ]] 
    then
	mkdir staged
	chmod u+rwx staged
    fi
    cd $curdir
    find *.xpi | while read line; do
	linelen=${#line}
        linelensub=$(($linelen - 4))
	if [ ! -f $extdir/$line ] && [ ! -d $extdir/${line:0:$linelensub} ]
	then
	    if [ -d ${line:0:$linelensub} ]
	    then
		if [[ $version == "3" ]]
		then
		    mkdir $extdir/${line:0:$linelensub}
		    chmod u+rwx $extdir/${line:0:$linelensub}
		    cp -r $line $extdir/${line:0:$linelensub}
		    echo $extdir/${line:0:$linelensub} >> .installed
		else
		    cp -r ${line:0:$linelensub} $extdir/staged
                    echo $extdir/${line:0:$linelensub} >> .installed
		fi
	    else
		if [[ $version == "3" ]]
                then
		    mkdir $extdir/${line:0:$linelensub}
                    chmod u+rwx $extdir/${line:0:$linelensub}
                    cp -r $line $extdir/${line:0:$linelensub}
		    chmod u+r $extdir/${line:0:$linelensub}/$line
		    unzip $extdir/${line:0:$linelensub}/$line
		    echo $extdir/${line:0:$linelensub} >> .installed
                else
		    cp $line $extdir/staged
		    echo $extdir/$line >> .installed
		fi
	    fi
	    if [[ $version != "3" ]]
	    then
		cp ${line:0:$linelensub}.json $extdir/staged
	    fi
	fi
    done
fi
