#!/bin/bash

set -e

stage3ver="20140313"
portagever="20140320"
kernelver="3.10.1-r1"

njobs=1
if [ ! -z "$1" ]
then
    njobs="$1"
fi

download_stage3() {
    echo "Downloading stage3 tarball ..."
    cd stage3
    if [ ! -f stage3-amd64-hardened-"$stage3ver".tar.bz2 ]
    then
	wget http://distfiles.gentoo.org/releases/amd64/autobuilds/20140313/hardened/stage3-amd64-hardened-20140313.tar.bz2
    fi
    sha512sum stage3-amd64-hardened-"$stage3ver".tar.bz2 | grep $(awk 'NR==2 { print $1 }' stage3-amd64-hardened-"$stage3ver".tar.bz2.DIGESTS) || (echo "Invalid file was downloaded. Please try again." && exit 1)
    cd ..
}

unpack_stage3() {
    echo "Unpacking stage3 tarball to source directory ..."
    mkdir source
    tar xjpf stage3/stage3-amd64-hardened-"$stage3ver".tar.bz2 -C source/
}

preconfigure_outside() {
    echo "Preconfiguring outside ..."
    sed 's/j1/j'"$njobs"'/' <make.conf >source/etc/portage/make.conf
    cp -L /etc/resolv.conf source/etc/
    mkdir source/root/tmp
    mkdir source/root/logs
    mkdir logs
    mkdir target
    mkdir target/live
    mkdir target/boot
}

mount_filesystems() {
    echo "Mounting special filesystems ..."
    mount -t proc proc source/proc
    mount --rbind /sys source/sys
    mount --rbind /dev source/dev
}

preconfigure_inside() {
    echo "Preconfiguring inside ..."
    cp portage/portage-"$portagever".tar.bz2 source/root/tmp/
    cp -r distfiles source/root/tmp/
    cp preconfigure.sh source/root/tmp/
    chroot source/ /root/tmp/preconfigure.sh "$portagever"
    rm source/root/tmp/preconfigure.sh
    rm -r source/root/tmp/distfiles
    rm source/root/tmp/portage-"$portagever".tar.bz2
}

rebuild_toolchain() { #not tested
    echo "Rebuilding toolchain ..."
    cp toolchain.sh source/root/tmp/
    chroot source/ /root/tmp/toolchain.sh
    rm source/root/tmp/toolchain.sh
}

rebuild_kernel() {
    echo "Rebuilding kernel ..."
    cp kernel_config source/root/tmp/
    cp kernel.sh source/root/tmp/
    chroot source/ /root/tmp/kernel.sh "$kernelver"
    rm source/root/tmp/kernel_config
    rm source/root/tmp/kernel.sh
    cp source/usr/src/linux/arch/x86/boot/bzImage target/live/vmlinuz
    cp source/root/logs/kernel_*.log logs/
}

configure_inside() {
    echo "Configuring inside ..."
    cp fstab source/root/tmp/
    cp hostname source/root/tmp/
    cp hosts source/root/tmp/
    cp inittab source/root/tmp/
    cp configure.sh source/root/tmp/
    chroot source/ /root/tmp/configure.sh
    rm source/root/tmp/configure.sh
    rm source/root/tmp/inittab
    rm source/root/tmp/hosts
    rm source/root/tmp/hostname
    rm source/root/tmp/fstab
}

rebuild_world() {
    echo "Rebuilding world ..."
    cp piratepack.xml source/root/tmp/
    cp -r piratepack-testing source/root/tmp/
    cp world source/root/tmp/
    cp package.accept_keywords source/root/tmp/
    cp package.use source/root/tmp/
    cp package.license source/root/tmp/
    cp snapshot.asc source/root/tmp/
    cp -r home source/root/tmp/
    cp locale.nopurge source/root/tmp/
    cp world.sh source/root/tmp/
    chroot source/ /root/tmp/world.sh
    rm source/root/tmp/world.sh
    rm source/root/tmp/locale.nopurge
    rm -r source/root/tmp/home
    rm source/root/tmp/snapshot.asc
    rm source/root/tmp/package.license
    rm source/root/tmp/package.use
    rm source/root/tmp/package.accept_keywords
    rm source/root/tmp/world
    rm -r source/root/tmp/piratepack-testing
    rm source/root/tmp/piratepack.xml
    cp source/root/logs/localepurge.log logs/
}

unmount_filesystems() {
    echo "Unmounting special filesystems ..."
    umount -l source/dev
    umount -l source/sys
    umount -l source/proc
}

postconfigure_outside() {
    echo "Postconfiguring outside ..."
    rm source/etc/resolv.conf
    rmdir source/root/tmp
    rm -r source/root/logs
    sed 's/j'"$njobs"'/j1/' <source/etc/portage/make.conf >make.conf.tmp
    cp make.conf.tmp source/etc/portage/make.conf
    rm make.conf.tmp
}

squash_filesystem() {
    echo "Squashing filesystem ..."
    rm -f target/live/filesystem.squashfs
    mksquashfs source target/live/filesystem.squashfs
}

rebuild_initramfs() {

    echo "Rebuilding initramfs ..."

    mkdir initramfs
    mkdir initramfs/root
    mkdir initramfs/etc
    mkdir initramfs/lib
    mkdir initramfs/bin
    mkdir initramfs/sbin
    mkdir -p initramfs/usr/bin
    mkdir -p initramfs/usr/sbin
    mkdir initramfs/proc
    mkdir initramfs/sys
    mkdir initramfs/dev
    mkdir initramfs/mnt

    tar -xjf busybox-1.21.0.tar.bz2
    cd busybox-1.21.0
    make defconfig
    #sed -e 's/.*STATIC.*/CONFIG_STATIC=y/' -i .config
    #sed -e 's/.*FEATURE_PREFER_APPLETS.*/CONFIG_FEATURE_PREFER_APPLETS=y/' -i .config
    #sed -e 's/.*FEATURE_SH_STANDALONE.*/CONFIG_FEATURE_SH_STANDALONE=y/' -i .config
    make
    #make install
    cd ../
    ldd busybox-1.21.0/busybox | awk '{ for(i = 1; i <= NF; i++) { if($i~/[/].*[.]so/)print $i; } }' | xargs dirname | xargs -t -I '{}' mkdir -p initramfs'{}'
    ldd busybox-1.21.0/busybox | awk '{ for(i = 1; i <= NF; i++) { if($i~/[/].*[.]so/)print $i; } }' | xargs -t -I '{}' cp '{}' initramfs'{}'
    cp busybox-1.21.0/busybox initramfs/bin/
    rm -r busybox-1.21.0

    tar -xzf squashfs4.2.tar.gz
    cd squashfs4.2/squashfs-tools
    make unsquashfs
    cd ../../
    ldd squashfs4.2/squashfs-tools/unsquashfs | awk '{ for(i = 1; i <= NF; i++) { if($i~/[/].*[.]so/)print $i; } }' | xargs dirname | xargs -t -I '{}' mkdir -p initramfs'{}'
    ldd squashfs4.2/squashfs-tools/unsquashfs | awk '{ for(i = 1; i <= NF; i++) { if($i~/[/].*[.]so/)print $i; } }' | xargs -t -I '{}' cp '{}' initramfs'{}'
    cp squashfs4.2/squashfs-tools/unsquashfs initramfs/bin/
    rm -r squashfs4.2

    cp init initramfs/

    cd initramfs
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../target/live/initramfs.cpio.gz
    cd ..
    rm -r initramfs
}

rebuild_iso() {
    echo "Rebuilding ISO ..."
    cp -r grub target/boot/
    grub2-mkrescue -o pirate-linux.iso target
}

clean() {
    echo "Cleaning ..."
    rm -r source
    rm -r target
    rm -r logs
    rm pirate-linux.iso
}

main() {
    download_stage3
    unpack_stage3
    preconfigure_outside
    mount_filesystems
    preconfigure_inside
    rebuild_kernel
    configure_inside
    rebuild_world
    unmount_filesystems
    postconfigure_outside
    squash_filesystem
    rebuild_initramfs
    rebuild_iso
    echo "Successfully built Pirate Linux"
}

main
