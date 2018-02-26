#!/bin/bash

set -e

umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
