#!/bin/sh
#
#  Build the jbigi library for i2p
#
#  To build a static library:
#     Set $I2P to point to your I2P installation
#     Set $JAVA_HOME to point to your Java SDK
#     build.sh
#       This script downloads gmp-4.3.2.tar.bz2 to this directory
#       (if a different version, change the VER= line below)
#
#  To build a dynamic library (you must have a libgmp.so somewhere in your system)
#     Set $I2P to point to your I2P installation
#     Set $JAVA_HOME to point to your Java SDK
#     build.sh dynamic
#
#  The resulting library is lib/libjbigi.so
#

rm -rf bin/local
mkdir -p lib bin/local

# Use 4.3.2 32bit CPUs.
# Use 5.0.2 64bit CPUs.
VER=4.3.2

# If JAVA_HOME isn't set, try to figure it out on our own
[ -z $JAVA_HOME ] && . ../find-java-home
if [ ! -f "$JAVA_HOME/include/jni.h" ]; then
    echo "ERROR: Cannot find jni.h! Looked in \"$JAVA_HOME/include/jni.h\"" >&2
    echo "Please set JAVA_HOME to a java home that has the JNI" >&2
    exit 1
fi

# Abort script on uncaught errors
set -e

download_gmp ()
{
if [ $(which wget) ]; then
    echo "Downloading ftp://ftp.gmplib.org/pub/gmp-${VER}/${TAR}"
    wget -N --progress=dot ftp://ftp.gmplib.org/pub/gmp-${VER}/${TAR}
else
    echo "ERROR: Cannot find wget." >&2
    echo >&2
    echo "Please download ftp://ftp.gmplib.org/pub/gmp-${VER}/${TAR}" >&2
    echo "manually and rerun this script." >&2
    exit 1
fi
}

extract_gmp ()
{
tar -xjf ${TAR} > /dev/null 2>&1|| (rm -f ${TAR} && download_gmp && extract_gmp || exit 1)
}

TAR=gmp-${VER}.tar.bz2

if [ "$1" != "dynamic" -a ! -d gmp-${VER} ]; then
    #if [ ! -f $TAR ]; then
        #download_gmp
    #fi

    echo "Building the jbigi library with GMP Version ${VER}"
    echo "Extracting GMP..."
    #extract_gmp
fi

cd bin/local

echo "Building..."
if [ "$1" != "dynamic" ]; then
    #case `uname -sr` in
        #Darwin*)
            # --with-pic is required for static linking
            #../../gmp-${VER}/configure --with-pic;;
        #*)
            # and it's required for ASLR
            #../../gmp-${VER}/configure --with-pic;;
    #esac
    #make
    sh ../../build_jbigi.sh static
else
    shift
    sh ../../build_jbigi.sh dynamic
fi

cp *jbigi???* ../../lib/
echo 'Library copied to lib/'
cd ../..
