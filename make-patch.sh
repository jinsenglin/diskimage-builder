#!/bin/bash

SRC=$1
REV=$2
PATCH=$SRC.patch

if [ -z $SRC -o -z $REV ]; then
    echo "Usage: $0 <src file> <rev file>"
    exit 1
fi

diff -Naur $SRC $REV > $PATCH
