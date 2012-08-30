read -p "set arch and cross-compiler"
export TOPDIR=$(cd $(dirname "$0"); pwd)
export MY_ARCH=arm
export MY_CROSS_COMPILE=$TOPDIR/buildtools/arm-eabi-4.4.3/bin/arm-eabi-
export MY_PRODUCT=$1
export MY_DEFCONF=champ_${MY_PRODUCT}_defconfig
export MY_KERNEL_VERSION=3.0.8

read -p "get into this directory"
cd $TOPDIR

read -p "go into kernel directory"
cd kernel

read -p "clean the build first"
ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE} make clean
ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE} make distclean

read -p "get defconfig"
ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE} make $MY_DEFCONF

read -p "change configurations if needed"
ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE} make menuconfig

read -p "compile the kernel"
ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE} make -j6

read -p "pull out kernel into compiled directory"
cd $TOPDIR
cp ${TOPDIR}/kernel/arch/arm/boot/zImage ${TOPDIR}/compiled/.

read -p "pull out kernel modules (if any)"
cd $TOPDIR
cp ${TOPDIR}/kernel/*/*.ko ${TOPDIR}/compiled/modules/.
cp ${TOPDIR}/kernel/*/*/*.ko ${TOPDIR}/compiled/modules/.
cp ${TOPDIR}/kernel/*/*/*/*.ko ${TOPDIR}/compiled/modules/.
cp ${TOPDIR}/kernel/*/*/*/*/*.ko ${TOPDIR}/compiled/modules/.
cp ${TOPDIR}/kernel/*/*/*/*/*/*.ko ${TOPDIR}/compiled/modules/.

read -p "go to wlan vendor and compile it"
cd ${TOPDIR}/vendor/broadcom/wlan/dhd/linux
make LINUXDIR=${TOPDIR}/kernel LINUXVER=${MY_KERNEL_VERSION} ARCH=${MY_ARCH} CROSS_COMPILE=${MY_CROSS_COMPILE}
cp ${TOPDIR}/vendor/broadcom/wlan/dhd/linux/dhd-android/bcm4330.ko ${TOPDIR}/compiled/modules/.
cp ${TOPDIR}/vendor/broadcom/wlan/dhd/linux/dhd-android/bcm4330.ko.stripped ${TOPDIR}/compiled/modules/.
make clean
cd $TOPDIR

