#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
#KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	if !(test -d ${OUTDIR})
	then
		mkdir -p ${OUTDIR}
		if [ $? -ne 0 ] ; then
			exit
		fi
	fi
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}
cp yylloc.patch ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
    echo "CLONING GIT2 LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    git apply ${OUTDIR}/yylloc.patch
    # TODO: Add your kernel build steps here
#    dependency_list=("bc" "u-boot-tools" "kmod" "cpio" "flex" "bison" "libssl-dev" "psmisc" "qemu-system-arm")
#    for i in ${dependency_list[@]}
#    do
#	if command -v "${i}" >/dev/null 2>&1 ; then
#		echo "${i} found"
#	else
#		echo "${i} not found"
#		sudo apt update && sudo apt install -y "${i}"
#	fi
 #   done
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

    cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir "${OUTDIR}/rootfs"
mkdir -p "${OUTDIR}/rootfs/bin" "${OUTDIR}/rootfs/dev" "${OUTDIR}/rootfs/etc" "${OUTDIR}/rootfs/home" "${OUTDIR}/rootfs/lib" 
mkdir -p "${OUTDIR}/rootfs/lib64" "${OUTDIR}/rootfs/proc" "${OUTDIR}/rootfs/sbin" "${OUTDIR}/rootfs/sys" "${OUTDIR}/rootfs/tmp"
mkdir -p "${OUTDIR}/rootfs/usr" "${OUTDIR}/rootfs/var"
mkdir -p "${OUTDIR}/rootfs/usr/bin" "${OUTDIR}/rootfs/usr/lib" "${OUTDIR}/rootfs/usr/sbin"
mkdir -p "${OUTDIR}/rootfs/var/log"

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
    #make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
    #make CONFIG_PREFIX="${OUTDIR}/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
else
    cd busybox
fi


# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX="${OUTDIR}/rootfs" ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd ${OUTDIR}/rootfs
echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
sysroot=$(${CROSS_COMPILE}gcc -print-sysroot)
cp "${sysroot}/lib/ld-linux-aarch64.so.1" "${OUTDIR}/rootfs/lib"
cp "${sysroot}/lib64/libm.so.6" "${OUTDIR}/rootfs/lib64"
cp "${sysroot}/lib64/libresolv.so.2" "${OUTDIR}/rootfs/lib64"
cp "${sysroot}/lib64/libc.so.6" "${OUTDIR}/rootfs/lib64"

# TODO: Make device nodes
sudo mknod -m 622 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 622 ${OUTDIR}/rootfs/dev/console c 5 1
sudo mknod -m 622 ${OUTDIR}/rootfs/dev/tty c 4 0

cd "$FINDER_APP_DIR"
# TODO: Clean and build the writer utility
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
mkdir "${OUTDIR}/rootfs/home/conf"
cp "finder.sh" "${OUTDIR}/rootfs/home"
cp "conf/username.txt" "${OUTDIR}/rootfs/home/conf"
cp "conf/assignment.txt" "${OUTDIR}/rootfs/home/conf"
cp "finder-test.sh" "${OUTDIR}/rootfs/home"

cp "autorun-qemu.sh" "${OUTDIR}/rootfs/home"
# TODO: Chown the root directory
sudo chown root:root "${OUTDIR}/rootfs"

# TODO: Create initramfs.cpio.gz
cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ../initramfs.cpio
