#!/bin/busybox sh

rescue_shell() {
	       echo "Something went wrong. Dropping you to a shell."
	       exec sh
}

/bin/busybox --install -s

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

mkdir /mnt/ramdisk
mount -t tmpfs -o noatime,size=3g tmpfs /mnt/ramdisk || rescue_shell

mkdir /mnt/target

echo "Scanning disks ..."

target_dev=0
ntrials=0
while [[ "$target_dev" == "0" ]]
do
    for dev in $(tail -n +2 /proc/partitions | awk '{print $4}')
    do
	if mount -o ro /dev/"$dev" /mnt/target 2>> /dev/null
	then
	    if [ -e /mnt/target/.uuid ]
	    then
		read -r candidate_id</mnt/target/.uuid
		if [[ "$candidate_id" == "$uuid" ]]
		then
		    if [ -e /mnt/target/live/filesystem.squashfs ]
		    then
			mem=$(head -n 1 /proc/meminfo | awk '{print $2}')
			if [ "$mem" -lt 3000000 ]
			then
			    echo "You need more RAM to use Pirate Linux Live"
			    rescue_shell
			fi
			echo "Checking filesystem ..."
			if sha512sum /mnt/target/live/filesystem.squashfs | grep "$filesystem_squashfs_shasum"
			then
			    echo "Unsquashing filesystem"
			    if /bin/unsquashfs -f -d /mnt/ramdisk /mnt/target/live/filesystem.squashfs
			    then
				target_dev=1 && break 
			    else
				rescue_shell
			    fi
			fi
		    fi
		fi
	    fi
	    umount /mnt/target || rescue_shell
	fi
    done
    if [[ "$target_dev" == "1" ]]
    then
	break
    fi
    ntrials=$(echo "$ntrials 1 + p" | dc)
    if [[ "$ntrials" == "1000" ]]
    then
	break
    fi
    sleep 1
done

if [[ "$target_dev" == "0" ]]
then
    rescue_shell
fi

mkdir tmp
ncpus=$(grep -c ^processor /proc/cpuinfo)
nj=$(echo "$ncpus 1 + p" | dc)
echo "nj = $nj"
sed 's/^MAKEOPTS[=].*$/MAKEOPTS="-j'"$nj"'"/' </mnt/ramdisk/etc/portage/make.conf >tmp/make.conf
mv tmp/make.conf /mnt/ramdisk/etc/portage/
rmdir tmp

umount /proc
umount /sys
umount /dev

exec /bin/busybox switch_root /mnt/ramdisk /sbin/init
