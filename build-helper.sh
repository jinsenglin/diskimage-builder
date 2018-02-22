#!/bin/bash

set -e
set -o pipefail

function show_env() {
    echo tty
    grep --color tty /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
    echo

    echo DIB_DEBUG_TRACE=$DIB_DEBUG_TRACE
    echo

    echo DIB_OFFLINE=$DIB_OFFLINE
    echo

    echo OVERWRITE_OLD_IMAGE=$OVERWRITE_OLD_IMAGE
    echo

    echo DIB_DEV_USER_PWDLESS_SUDO=$DIB_DEV_USER_PWDLESS_SUDO
    echo

    echo DIB_DEV_USER_USERNAME=$DIB_DEV_USER_USERNAME
    echo

    echo DIB_DEV_USER_PASSWORD=$DIB_DEV_USER_PASSWORD
    echo

    echo ELEMENTS_PATH=$ELEMENTS_PATH
    echo

    echo DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=$DIB_CLOUD_INIT_PATCH_SET_PASSWORDS
    echo

    echo DIB_CLOUD_INIT_PATCH_BOOTCMD=$DIB_CLOUD_INIT_PATCH_BOOTCMD
    echo

    echo DIB_CLOUD_INIT_DATASOURCES=$DIB_CLOUD_INIT_DATASOURCES
    echo
}

if [ $# -eq 1 ]; then
  fn=$(echo $1 | sed 's/-/_/g')
  $fn
fi 
