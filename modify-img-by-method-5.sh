#!/bin/bash

losetup /dev/loop0 centos7-baremetal.raw
kpartx -av /dev/loop0
mount /dev/mapper/loop0p1 /mnt
ls /mnt
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
