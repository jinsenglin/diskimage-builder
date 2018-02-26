#!/bin/bash

set -e

RAW=$1

if [ -z $RAW ]; then
    echo "Usage: $0 <raw file>"
    exit 1
fi

virt-install --connect=qemu:///system --name=centos7 --ram=512 --vcpus=1 --disk path=$RAW,format=raw --import --network network:default --vnc &
