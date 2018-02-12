#!/bin/bash

losetup /dev/loop0 centos7-baremetal.raw
kpartx -av /dev/loop0
mount /dev/mapper/loop0p1 /mnt
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
chroot /mnt

ls /home

exit
umount /mnt/sys
umount /mnt/dev
umount /mnt/proc
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
