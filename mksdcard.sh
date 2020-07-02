#!/bin/bash

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

# Format an SD card for AOSP on RPi3
KERNELDIR=kernel/arpi

if [ -z ${ANDROID_PRODUCT_OUT} ]; then
	echo "You must run lunch first"
	exit 1
fi

if [ $# -ne 1 ]; then
        echo "Usage: $0 [drive]"
        echo "       drive is 'sdb', 'mmcblk0'"
        exit 1
fi

DRIVE=$1

if [ -z $TARGET_PRODUCT ]; then
	echo "Please run 'lunch' first"
	exit
fi

# Check the drive exists in /sys/block
if [ ! -e /sys/block/${DRIVE}/size ]; then
	echo "Drive does not exist"
	exit 1
fi

# Check it is a flash drive (size < 32MiB)
NUM_SECTORS=`cat /sys/block/${DRIVE}/size`
if [ $NUM_SECTORS -eq 0 -o $NUM_SECTORS -gt 64000000 ]; then
	echo "Does not look like an SD card, bailing out"
	exit 1
fi

sleep 3

# Unmount any partitions that have been automounted
if [ $DRIVE == "mmcblk0" ]; then
	sudo umount /dev/${DRIVE}*
	BOOT_PART=/dev/${DRIVE}p1
	SYSTEM_PART=/dev/${DRIVE}p2
	VENDOR_PART=/dev/${DRIVE}p3
	USER_PART=/dev/${DRIVE}p4
else
	sudo umount /dev/${DRIVE}[1-9]
	BOOT_PART=/dev/${DRIVE}1
	SYSTEM_PART=/dev/${DRIVE}2
	VENDOR_PART=/dev/${DRIVE}3
	USER_PART=/dev/${DRIVE}4
fi

sleep 3

# Overwite existing partiton table with zeros
sudo dd if=/dev/zero of=/dev/${DRIVE} bs=1M count=10
if [ $? -ne 0 ]; then echo "Error: dd"; exit 1; fi

# Create 4 primary partitons on the sd card
#  1: boot:   FAT32, 128  MiB, boot flag 
#  2: system: Linux, 1024 MiB 
#  3: vendor: Linux, 256  MiB 
#  4: data:   Linux, 1024 MiB 

# Note that the formatting of parameters changed slightly v2.26
SFDISK_VERSION=`sfdisk --version | awk '{print $4}'`
if version_gt $SFDISK_VERSION "2.26"; then
     echo "sfdisk uses new syntax"
	sudo sfdisk /dev/${DRIVE} << EOF
,128M,0x0c,*
,1024M,,,
,256M,,,
,1024M,,,
EOF
else
	sudo sfdisk --unit M /dev/${DRIVE} << EOF
,128,0x0c,*
,1024,,,
,256,,,
,1024,,,
EOF
fi
if [ $? -ne 0 ]; then echo "Error: sdfisk"; exit 1; fi

# Format p1 with FAT32
sudo mkfs.vfat -F 16 -n boot ${BOOT_PART}
if [ $? -ne 0 ]; then echo "Error: mkfs.vfat"; exit 1; fi


# Copy boot files
echo "Mounting $BOOT_PART"
sudo mount $BOOT_PART /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi


sudo cp $ANDROID_BUILD_TOP/device/arpi/rpi4car/boot/* /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi

sudo cp $ANDROID_BUILD_TOP/kernel/arpi/arch/arm/boot/zImage /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi

sudo cp ${ANDROID_PRODUCT_OUT}/ramdisk.img /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi

sudo cp $ANDROID_BUILD_TOP/kernel/arpi/arch/arm/boot/dts/bcm2711-rpi-4-b.dtb /mnt
if [ $? != 0 ]; then echo "ERROR"; exit; fi

sudo mkdir /mnt/overlays

sudo cp $ANDROID_BUILD_TOP/kernel/arpi/arch/arm/boot/dts/overlays/vc4-kms-v3d-pi4.dtbo /mnt/overlays

sudo cp $ANDROID_BUILD_TOP/${KERNELDIR}/arch/arm/boot/dts/overlays/*.dtbo /mnt/overlays
if [ $? != 0 ]; then echo "ERROR"; exit; fi

sync
sudo umount /mnt

# Create bmap files
bmaptool create -o ${ANDROID_PRODUCT_OUT}/system.img.bmap ${ANDROID_PRODUCT_OUT}/system.img
bmaptool create -o ${ANDROID_PRODUCT_OUT}/userdata.img.bmap ${ANDROID_PRODUCT_OUT}/userdata.img
bmaptool create -o ${ANDROID_PRODUCT_OUT}/vendor.img.bmap ${ANDROID_PRODUCT_OUT}/vendor.img

# Copy disk images
echo "Writing system"
sudo bmaptool copy ${ANDROID_PRODUCT_OUT}/system.img $SYSTEM_PART
#sudo dd if=${ANDROID_PRODUCT_OUT}/system.img of=$SYSTEM_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $SYSTEM_PART system
#
echo "Writing userdata"
sudo bmaptool copy ${ANDROID_PRODUCT_OUT}/userdata.img $USER_PART
#sudo dd if=${ANDROID_PRODUCT_OUT}/userdata.img of=$USER_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $USER_PART userdata
#
echo "Writing vendor"
sudo bmaptool copy ${ANDROID_PRODUCT_OUT}/vendor.img $VENDOR_PART
#sudo dd if=${ANDROID_PRODUCT_OUT}/vendor.img of=$VENDOR_PART bs=1M
if [ $? != 0 ]; then echo "ERROR"; exit; fi
sudo e2label $VENDOR_PART vendor

echo "SUCCESS! Andrdoid installed on the uSD card. Enjoy"

exit 0

