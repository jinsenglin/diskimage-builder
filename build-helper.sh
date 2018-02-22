#!/bin/bash

set -eu
set -o pipefail

function show_env() {
    echo tty
    grep --color tty /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
    echo
}

if [ $# -eq 1 ]; then
  fn=$(echo $1 | sed 's/-/_/g')
  $fn
fi 
