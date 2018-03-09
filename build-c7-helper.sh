#!/bin/bash

set -e
set -o pipefail

fn_array=(show-env build-cloud_init_dev build-license_dev build-vm_c7 build-vm_c7_sc_dev build-bm_c7 build-bm_c7_k80 build-bm_c7_k80_nvidia_docker)

function show_env() {
    echo tty
    grep --color tty /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
    echo

    echo DIB_BOOTLOADER_DEFAULT_CMDLINE=$DIB_BOOTLOADER_DEFAULT_CMDLINE
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

    echo DIB_CLOUD_INIT_PATCH_RUNCMD=$DIB_CLOUD_INIT_PATCH_RUNCMD
    echo

    echo DIB_CLOUD_INIT_PATCH_RUNCMD_VERSION=$DIB_CLOUD_INIT_PATCH_RUNCMD_VERSION
    echo

    echo DIB_CLOUD_INIT_DATASOURCES=$DIB_CLOUD_INIT_DATASOURCES
    echo

    echo DIB_NVIDIA_K80_DRIVER=$DIB_NVIDIA_K80_DRIVER
    echo

    echo DIB_NVIDIA_CUDA_TOOLKIT=$DIB_NVIDIA_CUDA_TOOLKIT
    echo

    echo DIB_NVIDIA_CUDNN_CUDA_HOME=$DIB_NVIDIA_CUDNN_CUDA_HOME
    echo

    echo DIB_NVIDIA_CUDNN_LIBRARY=$DIB_NVIDIA_CUDNN_LIBRARY
    echo

    echo DIB_LICENSE_ENDPOINT=$DIB_LICENSE_ENDPOINT
    echo

    echo DIB_LICENSE_CLIENT_CERT=$DIB_LICENSE_CLIENT_CERT
    echo

    echo DIB_LICENSE_CLIENT_KEY=$DIB_LICENSE_CLIENT_KEY
    echo

    echo DIB_LICENSE_VAULT=$DIB_LICENSE_VAULT
    echo
}

function _common_build_options() {
    export ELEMENTS_PATH=$PWD/elements
    export DIB_OFFLINE=1
    export OVERWRITE_OLD_IMAGE=1
    export DIB_DEV_USER_PWDLESS_SUDO="yes"
    export DIB_DEV_USER_USERNAME="cclin"
    export DIB_DEV_USER_PASSWORD="cclin"
}

function build_cloud_init_dev() {
    _common_build_options

    #bash hack-upstream-elements/switch-to-tty0.sh
    unset DIB_BOOTLOADER_DEFAULT_CMDLINE

    unset DIB_CLOUD_INIT_DATASOURCES
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud cloud-init-patch -o cloud-init-dev
    fi
}

function build_license_dev() {
    _common_build_options

    #bash hack-upstream-elements/switch-to-tty0.sh
    unset DIB_BOOTLOADER_DEFAULT_CMDLINE

    unset DIB_CLOUD_INIT_DATASOURCES
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1
    export DIB_LICENSE_ENDPOINT=https://192.168.240.56.xip.io/wsgi
    export DIB_LICENSE_CLIENT_CERT=http://192.168.240.56.xip.io/client.cert.pem
    export DIB_LICENSE_CLIENT_KEY=http://192.168.240.56.xip.io/client.key.pem
    export DIB_LICENSE_VAULT=http://192.168.240.56.xip.io/src.des3

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud cloud-init-patch license -o license-dev
    fi
}

function build_vm_c7() {
    _common_build_options

    unset DIB_BOOTLOADER_DEFAULT_CMDLINE

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch -o vm-c7
    fi
}

function build_vm_c7_sc_dev() {
    _common_build_options
    export ELEMENTS_PATH=$ELEMENTS_PATH:/opt/3rd-party-dib-elements

    unset DIB_BOOTLOADER_DEFAULT_CMDLINE
    #export DIB_BOOTLOADER_DEFAULT_CMDLINE="console=tty1 console=ttyS1,115200 crashkernel=auto"

    unset DIB_CLOUD_INIT_DATASOURCES
    #export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive

    export DIB_DEV_USER_USERNAME=devuser    # used by sc-dashboard
    export DIB_DEV_USER_PASSWORD=Abc12345   # used by sc-dashboard

    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1
    export DIB_CLOUD_INIT_PATCH_RUNCMD_VERSION=v2
    export DIB_LICENSE_ENDPOINT=https://192.168.240.56.xip.io/wsgi
    export DIB_LICENSE_CLIENT_CERT=http://192.168.240.56.xip.io/client.cert.pem
    export DIB_LICENSE_CLIENT_KEY=http://192.168.240.56.xip.io/client.key.pem
    export DIB_LICENSE_VAULT=http://192.168.240.56.xip.io/src.des3

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud cloud-init-patch license ansible sc-dashboard -o vm-c7-sc-dev
        #disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch license ansible sc-dashboard -o vm-c7-sc
    fi
}


function build_bm_c7() {
    _common_build_options

    #bash hack-upstream-elements/switch-to-tty1.sh
    DIB_BOOTLOADER_DEFAULT_CMDLINE="console=tty1 console=ttyS1,115200 crashkernel=auto"

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch -o bm-c7
    fi
}

function build_bm_c7_k80() {
    _common_build_options

    #bash hack-upstream-elements/switch-to-tty1.sh
    DIB_BOOTLOADER_DEFAULT_CMDLINE="console=tty1 console=ttyS1,115200 crashkernel=auto"

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=0

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-tesla-k80-driver -o bm-c7-k80 --image-size 3
        cat <<DATA
# verify
nvidia-smi
DATA
    fi
}

function build_bm_c7_k80_nvidia_docker() {
    _common_build_options

    #bash hack-upstream-elements/switch-to-tty1.sh
    DIB_BOOTLOADER_DEFAULT_CMDLINE="console=tty1 console=ttyS1,115200 crashkernel=auto"

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=0
    export DIB_CLOUD_INIT_PATCH_RUNCMD=1
    export DIB_NVIDIA_K80_DRIVER=http://localhost:8000/nvidia-diag-driver-local-repo-rhel7-390.12-1.0-1.x86_64.rpm
    export DIB_NVIDIA_CUDA_TOOLKIT=http://localhost:8000/cuda-repo-rhel7-9-1-local-9.1.85-1.x86_64.rpm
    export DIB_NVIDIA_CUDNN_LIBRARY=http://localhost:8000/cudnn-9.1-linux-x64-v7.tgz

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-y} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-docker -o bm-c7-k80-cuda-cudnn-nvidia_docker --image-size 6
        cat <<DATA
# verify
systemctl start docker
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
DATA
    fi
}


if [ $# -eq 1 ]; then
    fn=$(echo $1 | sed 's/-/_/g')
    $fn
else
    echo "available subcommnd: ${fn_array[@]}"
fi 
