#!/bin/bash

set -eu
set -o pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <mk-safebox | rm-puzzles>"
    exit 1
fi

SAFEBOX_PASS=${SAFEBOX_PASS:-CN: client}
D_VERSION=${D_VERSION:-0948b87ab6f2bcb6e492cc6c082e5f43403ba256}
E_VERSION=${E_VERSION:-HEAD}

function mk_safebox() {
    mkdir safebox

    git clone http://172.16.100.91/tonycheng/dib-element.git
    cd dib-element
        git checkout $D_VERSION
        mv sc-dashboard/static/root/cascade-dashboard-dib-ansible ../safebox/cascade-dashboard-dib-ansible
        mv sc-dashboard/static/root/install-sc-dashboard.sh ../safebox/install-sc-dashboard.sh
    cd ..
    rm -rf dib-element

    tar -zcvf - safebox | openssl des3 -salt -k $SAFEBOX_PASS | dd of=safebox.des3
    rm -rf safebox

    echo "File 'safebox.des3' is generated."
}

function rm_puzzles() {
    losetup /dev/loop0 $RAW_IMAGE
    kpartx -av /dev/loop0
    mount /dev/mapper/loop0p1 /mnt

        rm -rf /mnt/root/cascade-dashboard-dib-ansible
        rm -rf /mnt/root/install-sc-dashboard.sh

    umount /mnt
    kpartx -d /dev/loop0
    losetup -d /dev/loop0

    echo "File '$RAW_IMAGE' is modified."
}

CMD=$(echo $1 | sed 's/-/_/g')
$CMD
