#!/bin/bash

set -e

RAW=$1

if [ -z $RAW ]; then
    echo "Usage: $0 <raw file>"
    exit 1
fi

losetup /dev/loop0 $RAW
kpartx -av /dev/loop0
mount /dev/mapper/loop0p1 /mnt
