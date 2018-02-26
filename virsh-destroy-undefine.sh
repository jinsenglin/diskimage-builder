#!/bin/bash

set -e

virsh destroy centos7
virsh -c qemu:///system undefine centos7
