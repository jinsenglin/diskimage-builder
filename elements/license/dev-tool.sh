#!/bin/bash

set -eu
set -o pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <mk-safebox | rm-puzzles>"
    exit 1
fi

SAFEBOX_PASS=${SAFEBOX_PASS:-CN: client}
D_VERSION=${D_VERSION:-HEAD}
E_VERSION=${E_VERSION:-HEAD}

function mk_safebox() {
    mkdir safebox

#    git clone http://172.16.100.91/tonycheng/dib-element.git
#    cd dib-element
#        git checkout $D_VERSION
#        mv sc-dashboard/static/root/cascade-dashboard-dib-ansible ../safebox/cascade-dashboard-dib-ansible
#        mv sc-dashboard/static/root/install-sc-dashboard.sh ../safebox/install-sc-dashboard.sh
#    cd ..
#    rm -rf dib-element

    losetup /dev/loop0 $RAW_IMAGE
    kpartx -av /dev/loop0
    mount /dev/mapper/loop0p1 /mnt

        mv /mnt/root/cascade-dashboard-dib-ansible safebox/
        mv /mnt/root/install-sc-dashboard.sh safebox/

    umount /mnt
    kpartx -d /dev/loop0
    losetup -d /dev/loop0

    tar -zcvf - safebox | openssl des3 -salt -k "$SAFEBOX_PASS" | dd of=safebox.des3
    rm -rf safebox

    echo "File 'safebox.des3' is generated."
}

function rm_puzzles() {
    #export LIBGUESTFS_BACKEND=direct
    #guestfish -a $RAW_IMAGE -i rm-rf /root/cascade-dashboard-dib-ansible
    #guestfish -a $RAW_IMAGE -i rm /root/install-sc-dashboard.sh

    # -----------------------------

    losetup /dev/loop0 $RAW_IMAGE
    kpartx -av /dev/loop0
    mount /dev/mapper/loop0p1 /mnt

        rm -rf /mnt/root/cascade-dashboard-dib-ansible
        rm -f /mnt/root/install-sc-dashboard.sh

    umount /mnt
    kpartx -d /dev/loop0
    losetup -d /dev/loop0

    # ------------------------------

    #losetup /dev/loop0 $RAW_IMAGE
    #kpartx -av /dev/loop0
    #mount /dev/mapper/loop0p1 /mnt

    #    find /mnt/root/cascade-dashboard-dib-ansible -type f | while read line; do dd if=/dev/zero of=$line bs=1k count=1024; done
    #    rm -rf /mnt/root/cascade-dashboard-dib-ansible
    #    dd if=/dev/zero of=/mnt/root/install-sc-dashboard.sh bs=1k count=1024
    #    rm -f /mnt/root/install-sc-dashboard.sh

    #umount /mnt
    #kpartx -d /dev/loop0
    #losetup -d /dev/loop0

    # ------------------------------

    losetup /dev/loop0 $RAW_IMAGE
    kpartx -av /dev/loop0
    mount /dev/mapper/loop0p1 /mnt
    ls /mnt/root/ # check again
    umount /mnt
    kpartx -d /dev/loop0
    losetup -d /dev/loop0

    echo "File '$RAW_IMAGE' is modified."
}

CMD=$(echo $1 | sed 's/-/_/g')
$CMD
