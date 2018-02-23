#!/bin/bash

set -e
set -o pipefail

fn_array=(show-env build-cloud_init_dev build-bm_c7_k80 build-bm_c7_k80_nvidia_docker)

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

    echo DIB_NVIDIA_K80_DRIVER=$DIB_NVIDIA_K80_DRIVER
    echo

    echo DIB_NVIDIA_CUDA_TOOLKIT=$DIB_NVIDIA_CUDA_TOOLKIT
    echo

    echo DIB_NVIDIA_CUDNN_CUDA_HOME=$DIB_NVIDIA_CUDNN_CUDA_HOME
    echo

    echo DIB_NVIDIA_CUDNN_LIBRARY=$DIB_NVIDIA_CUDNN_LIBRARY
    echo
}

function _common_build_options() {
    export DIB_OFFLINE=1
    export OVERWRITE_OLD_IMAGE=1
    export DIB_DEV_USER_PWDLESS_SUDO="yes"
    export DIB_DEV_USER_USERNAME="cclin"
    export DIB_DEV_USER_PASSWORD="cclin"
}

function build_cloud_init_dev() {
    _common_build_options

    bash hack-upstream-elements/switch-to-tty0.sh

    unset DIB_CLOUD_INIT_DATASOURCES
    export ELEMENTS_PATH=$PWD/elements
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=1

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-n} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud cloud-init-patch -o centos7-baremetal
    fi
}

function build_bm_c7_k80() {
    _common_build_options

    bash hack-upstream-elements/switch-to-tty1.sh

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export ELEMENTS_PATH=$PWD/elements
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-n} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-tesla-k80-driver -o centos7-baremetal --image-size 3
    fi

    cat <<DATA
# verify
nvidia-smi
DATA
}

function build_bm_c7_k80_nvidia_docker() {
    _common_build_options

    bash hack-upstream-elements/switch-to-tty1.sh

    export DIB_CLOUD_INIT_DATASOURCES=ConfigDrive
    export ELEMENTS_PATH=$PWD/elements
    export DIB_CLOUD_INIT_PATCH_SET_PASSWORDS=1
    export DIB_CLOUD_INIT_PATCH_BOOTCMD=1
    export DIB_NVIDIA_K80_DRIVER=http://localhost:8000/nvidia-diag-driver-local-repo-rhel7-390.12-1.0-1.x86_64.rpm
    export DIB_NVIDIA_CUDA_TOOLKIT=http://localhost:8000/cuda-repo-rhel7-9-1-local-9.1.85-1.x86_64.rpm
    export DIB_NVIDIA_CUDNN_LIBRARY=http://localhost:8000/cudnn-9.1-linux-x64-v7.tgz

    show_env

    echo -n "Build ? (default: y) [y/n] "
    read ans

    if [ ${ans:-n} == "y" ]; then
        disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-docker -o centos7-baremetal --image-size 6
    fi

    cat <<DATA
# post-install
cd /
rpm -i cuda-repo-rhel7-9-1-local-9.1.85-1.x86_64.rpm
yum clean all
yum -y install cuda

cd /
tar -zxf cudnn-9.1-linux-x64-v7.tgz
cp cuda/include/cudnn.h /usr/local/cuda-9.1/include/
cp cuda/lib64/libcudnn* /usr/local/cuda-9.1/lib64/
chmod a+r /usr/local/cuda-9.1/include/cudnn.h
chmod a+r /usr/local/cuda-9.1/lib64/libcudnn*
ln -sf /usr/local/cuda-9.1 /usr/local/cuda

systemctl start docker

# verify
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
DATA
}


if [ $# -eq 1 ]; then
    fn=$(echo $1 | sed 's/-/_/g')
    $fn
else
    echo "available subcommnd: ${fn_array[@]}"
fi 
