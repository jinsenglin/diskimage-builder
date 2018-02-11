```
vagrant up
vagrant ssh
sudo su
```

```
# working dir: /home/vagrant

yum -y install epel-release
yum -y update
yum -y install python-pip

pip install diskimage-builder
yum -y install qemu-img

export DIB_DEV_USER_PWDLESS_SUDO="yes"
export DIB_DEV_USER_USERNAME="cclin"
export DIB_DEV_USER_PASSWORD="cclin"

# Build Option 1
# - testing my own element
mkdir /home/vagrant/cclin
export DIB_OFFLINE=1
export DIB_DEBUG_TRACE=1
export OVERWRITE_OLD_IMAGE=1
export ELEMENTS_PATH=/home/vagrant
disk-image-create -t raw centos7 vm dhcp-all-interfaces devuser cloud-init-nocloud cclin -o centos7-baremetal

# Build Option 2
# - with "grub2" element inside base image
# - with "openssh-server" element inside base image
# - use "/var/lib/cloud/seed/nocloud/{meta-data,user-data}" for cloud-init datasource
disk-image-create -t raw centos7 vm dhcp-all-interfaces enable-serial-console selinux-permissive devuser cloud-init-nocloud -o centos7-baremetal

# Build Option 3
# - use "ConfigDrive" for cloud-init datasource
export DIC_CLOUD_INIT_DATASOURCES="ConfigDrive"
disk-image-create -t raw centos7 vm dhcp-all-interfaces enable-serial-console selinux-permissive devuser -o centos7-baremetal

# cache dir: /root/.cache/image-create
# base image: http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz

yum -y install libguestfs-tools
yum -y install libvirt
service libvirtd start

# Inspect Method 1 :: [ virt-df ] 
export LIBGUESTFS_BACKEND=direct
virt-df -a centos7-baremetal.raw

# Sample Output
#
# Filesystem                           1K-blocks       Used  Available  Use%
# centos7-baremetal.raw:/dev/sda1        1781200    1142992     523716   65%
#

# Modify Method 1 :: [ guestfish ]
export LIBGUESTFS_BACKEND=direct
guestfish --ro -a centos7-baremetal.raw
run
list-filesystems
exit

# Modify Method 2 :: [ virt-edit ]
export LIBGUESTFS_BACKEND=direct
virt-edit -a centos7-baremetal.raw /etc/hosts

# Modify Method 3 :: [ guestmount ]
export LIBGUESTFS_BACKEND=direct
guestmount -a centos7-baremetal.raw -m /dev/sda1 --ro /mnt
ls /mnt
umount /mnt

# Modify Method 4 :: [ guestmount ] + [ chroot ]
export LIBGUESTFS_BACKEND=direct
guestmount -a centos7-baremetal.raw -m /dev/sda1 --rw /mnt
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
chroot /mnt
ls /home
exit
umount /mnt/sys
umount /mnt/dev
umount /mnt/proc
guestunmount /mnt #OR umount /mnt

# Modify Method 5 :: [ losetup ] + [ kpartx ]
losetup -f # result: /dev/loop0
losetup /dev/loop0 centos7-baremetal.raw
kpartx -av /dev/loop0 # result: add map loop0p1 (253:3): 0 3886464 linear /dev/loop0 2048
ls -l /dev/mapper/loop0p*
mount /dev/mapper/loop0p1 /mnt
ls /mnt
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
```

```
cp centos7-baremetal.raw /tmp
cd /tmp
chown qemu:qemu centos7-baremetal.raw

virt-install --connect=qemu:///system --name=centos7 --ram=512 --vcpus=1 --disk path=centos7-baremetal.raw,format=raw --import --network network:default --vnc
```

```
# REF http://accelazh.github.io/virtualization/Play-With-Libvirt-KVM

cd /tmp
wget --no-check-certificate https://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img
chown qemu:qemu cirros-0.3.2-x86_64-disk.img

yum -y install virt-install virt-viewer seabios-bin
virt-install --connect=qemu:///system --name=cirros --ram=512 --vcpus=1 --disk path=cirros-0.3.2-x86_64-disk.img,format=qcow2 --import --network network:default --vnc
^z
bg

# virsh list
# ls /etc/libvirt/qemu/cirros.xml
# ps aux | grep qemu-kvm

# virsh
# console cirros
# ^]
# exit

# virsh
# destroy cirros
# exit
# virsh -c qemu:///system undefine cirros # will remove /etc/libvirt/qemu/cirros.xml too
```

```
# inside centos7-baremetal.raw

## create user-data and meta-data files that will be used
## to modify image on first boot

cd /var/lib/cloud/seed/nocloud

cat > meta-data <<METADATA
local-hostname: centos7
METADATA

## will setup hostname "centos7"

cat > user-data <<USERDATA
#cloud-config
password: passw0rd
chpasswd: { expire: False }
ssh_pwauth: True
USERDATA

## will setup password "passw0rd" for the cloud user specified in the /etc/cloud/cloud.cfg , which means "centos" in this case

cat > user-data <<USERDATA
#cloud-config
chpasswd:
  list: |
    root:pass2000
    centos:pass2000
  expire: False
ssh_pwauth: True
USERDATA

## will setup password "pass2000" for existing user "root"
## will setup password "pass2000" for existing user "centos"
```

```
yum -y install qemu-system-x86

cp centos7-baremetal.raw /tmp
cd /tmp
chown qemu:qemu centos7-baremetal.raw

qemu-system-x86_64 centos7-baremetal.raw,format=raw -vnc :0
```

# Addiontional Resources

* https://docs.openstack.org/diskimage-builder/latest/
* create image https://docs.openstack.org/image-guide/centos-image.html
* create image https://docs.openstack.org/image-guide/create-images-automatically.html
* modify image https://docs.openstack.org/image-guide/modify-images.html
* https://github.com/openstack/octavia/blob/master/diskimage-create/diskimage-create.sh
* nocloud http://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
* inject root password http://madorn.com/cloud-init-admin-pass.html#.Wn6wNJP1XBI
* inject root password http://blog.csdn.net/sinat_22597285/article/details/76981218
* inject root password https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/installation_and_configuration_guide/setting_up_cloud_init
* inject root password https://zhangchenchen.github.io/2017/01/13/openstack-init-instance-password/
* element of driver type https://github.com/openstack/diskimage-builder/tree/master/diskimage_builder/elements/mellanox
* OVERWRITE_OLD_IMAGE https://docs.openstack.org/diskimage-builder/latest/developer/invocation.html
* DIB_OFFLINE https://docs.openstack.org/diskimage-builder/latest/developer/caches.html
* ELEMENTS_PATH https://docs.openstack.org/diskimage-builder/latest/developer/invocation.html
* Element Phase Subdirectories https://docs.openstack.org/diskimage-builder/latest/developer/developing_elements.html
* Element Dependencies https://docs.openstack.org/diskimage-builder/latest/developer/developing_elements.html
* sample install.d/99-ele https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/devuser/install.d/50-devuser
* sample environment.d/99-ele https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/devuser/environment.d/50-devuser
* sample download then install rpm https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/proliant-tools/install.d/65-proliant-tools-install
* initrd initramfs rootfs http://blog.linux.org.tw/~jserv/archives/001954.html
* qemu-system-x86_64 vnc https://www.cyberciti.biz/faq/linux-kvm-vnc-for-guest-machine/
