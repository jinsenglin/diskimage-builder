#!/bin/bash

TARGET=$1
PATCH=$2

if [ -z $TARGET -o -z $PATCH ]; then
    echo "Usage: $0 <target file> <patch file>"
    exit 1
fi

patch -F 0 -f $TARGET < $PATCH
