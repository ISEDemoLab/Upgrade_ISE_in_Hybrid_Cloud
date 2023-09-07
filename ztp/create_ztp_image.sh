#!/bin/bash
###########################################################
# This script is used to generate ise ztp image with ztp
# configuration file.
#
# Need to pass ztp configuration file as input.
#
# Copyright (c) 2021 by Cisco Systems, Inc.
# All rights reserved.
# Note:
# To mount the image use below command
# mount ise_ztp_config.img /ztp
# To mount the image from cdrom
# mount -o ro /dev/sr1 /ztp
#############################################################
if [ -z "$1" ];then
echo "Usage:$0 <ise-ztp.conf> [out-ztp.img]"
exit 1
elif [ ! -f $1 ];then
echo "file $1 not exist"
exit 1
else
conf_file=$1
fi
if [ -z "$2" ] ;then
image=ise_config.img
else
image=$2
fi
mountpath=/tmp/ise_ztp
ztplabel=ISE-ZTP
rm -fr $mountpath
mkdir -p $mountpath
dd if=/dev/zero of=$image bs=1k count=1440 > /dev/null 2>&1
if [ `echo $?` -ne 0 ];then
echo "Image creation failed\n"
exit 1
fi
mkfs.ext4 $image -L $ztplabel -F > /dev/null 2>&1
mount -o rw,loop $image $mountpath
cp $conf_file $mountpath/ise-ztp.conf
sync
umount $mountpath
sleep 1
# Check for automount and unmount
automountpath=$(mount | grep $ztplabel | awk '{print $3}')
if [ -n "$automountpath" ];then
umount $automountpath
fi
echo "Image created $image"
