Pirate Linux is a Linux based operating system that enhances privacy, free speech, and transparency. It is based on Gentoo and the Gentoo-hardened kernel. Visit our home page at https://piratelinux.org

To build the OS, you will need:

- A standard Linux toolset (binutils)
- chroot (requires root access)
- squashfs-tools (for mksquashfs and unsquashfs)
- grub-2 and libisoburn (for grub2-mkrescue)
- uuidgen (util-linux)
- cpio
- An internet connection with /etc/resolv.conf available (All downloaded files will be checked against checksums signed by the official Gentoo portage snapshot sigining key, included as snapshot.asc). If you want to build without an internet connection, then you have to place all the needed distfiles/source code packages used by portage inside the `distfiles` directory.

Note: The build script will fail as soon as it issues a command that fails or is not found. So it is safe to just try it out even if you are not sure that you have all the dependencies. For security purposes, you can run it in a virtual machine.

Once you're ready, issue the command:
```
./build.sh [nJobs]
```
where `[nJobs]` is the number of parallel jobs to use for compiling packages (the MAKEOPTS variable). It is an optional argument, and will not affect the make.conf of the final image (it will have MAKEOPTS="-j1").

For example:
```
./build.sh 5
```
will build Pirate Linux with at most 5 parallel compiling jobs, and should take about 6 hours to complete on a standard desktop with 4 cores. Once the build process is complete, you will see: "Successfully built Pirate Linux". The resulting ISO containing the OS is pirate-linux.iso. It should be similar to the latest prebuilt ISO available in the Downloads section of our website. Read https://piratelinux.org/?p=567 for more documentation for how to use this ISO.

Pirate Linux is released into the public domain (CC0), so feel to do what you want with it. For more details, see the LICENSE file.
