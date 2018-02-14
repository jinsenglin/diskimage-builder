```
# vagrant host

vagrant up
vagrant ssh
```

```
# vagrant guest
# working dir /home/vagrant

sudo su

# install diskimage-builder
#
yum -y install epel-release
yum -y update
yum -y install python-pip qemu-img
pip install diskimage-builder
#

# pin base image version
#
# wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1503.qcow2.xz
# export DIB_CLOUD_IMAGES=$PWD/CentOS-7-x86_64-GenericCloud-1503.qcow2.xz
#

# change disk image layout
#
# source DIB_BLOCK_DEVICE_CONFIG-for-vm-of-2-partitions
#

export DIB_DEBUG_TRACE=1
export DIB_OFFLINE=1
export OVERWRITE_OLD_IMAGE=1

export DIB_DEV_USER_PWDLESS_SUDO="yes"
export DIB_DEV_USER_USERNAME="cclin"
export DIB_DEV_USER_PASSWORD="cclin"

# Build Option 0
disk-image-create -t raw centos7 baremetal -o centos7-baremetal # The partition image command creates .raw, .vmlinuz and .initrd files.
disk-image-create -t raw centos7 vm -o centos7-baremetal # The whole disk image command creates .raw file.
disk-image-create -t raw centos7 vm selinux-permissive devuser cloud-init-nocloud -o centos7-baremetal

# Build Option 1 - to test custom element "cclin"
# - use "/var/lib/cloud/seed/nocloud/{meta-data,user-data}" for cloud-init datasource
export ELEMENTS_PATH=/vagrant/elements # built-in elements reside in /usr/lib/python2.7/site-packages/diskimage_builder/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud cclin -o centos7-baremetal

# Build Option 2
# - use "/var/lib/cloud/seed/nocloud/{meta-data,user-data}" for cloud-init datasource
export ELEMENTS_PATH=/vagrant/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-nocloud docker -o centos7-baremetal

# Build Option 3
# - use "ConfigDrive" for cloud-init datasource
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
export ELEMENTS_PATH=/vagrant/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-tesla-k80-driver -o centos7-baremetal --image-size 3

# Build Option 4
# - use "ConfigDrive" for cloud-init datasource
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
export ELEMENTS_PATH=/vagrant/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-cuda-toolkit -o centos7-baremetal --image-size 5

# Build Option 5
# - use "ConfigDrive" for cloud-init datasource
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
export ELEMENTS_PATH=/vagrant/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-cudnn-library -o centos7-baremetal --image-size 5

# Build Option 6
# - use "ConfigDrive" for cloud-init datasource
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
export ELEMENTS_PATH=/vagrant/elements
disk-image-create -t raw centos7 vm dhcp-all-interfaces selinux-permissive devuser cloud-init-patch nvidia-docker -o centos7-baremetal --image-size 5

# cache dir: /root/.cache/image-create
# base image: http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz

# install libguestfs-tools
#
yum -y install libguestfs-tools libvirt
service libvirtd start
#

# Inspect Method 1 :: [ qemu-img ]
qemu-img centos7-baremetal.raw

# Sample Output
#
# image: /home/vagrant/centos7-baremetal.raw
# file format: raw
# virtual size: 3.0G (3221225472 bytes)
# disk size: 2.9G
# 

# Inspect Method 2 :: [ virt-df ]
export LIBGUESTFS_BACKEND=direct
virt-df -a centos7-baremetal.raw

# Sample Output
#
# Filesystem                           1K-blocks       Used  Available  Use%
# centos7-baremetal.raw:/dev/sda1        1781200    1142992     523716   65%
#

# To Resize /dev/sda1 at build time phase
#
# --image-size 3
#
# centos7-baremetal.raw:/dev/sda1        2881392    1187332    1520492   42%
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

# Modify Method 6 :: [ losetup ] + [ kpartx ] + [ chroot ]
losetup -f # result: /dev/loop0
losetup /dev/loop0 centos7-baremetal.raw
kpartx -av /dev/loop0 # result: add map loop0p1 (253:3): 0 3886464 linear /dev/loop0 2048
ls -l /dev/mapper/loop0p*
mount /dev/mapper/loop0p1 /mnt
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /sys /mnt/sys
chroot /mnt
ls /home
exit
umount /mnt/sys
umount /mnt/dev
umount /mnt/proc
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

qemu-system-x86_64 centos7-baremetal.raw -nographic

yum -y install vnc-server

qemu-system-x86_64 centos7-baremetal.raw -vnc :0 # netstat -plnt | grep 5900
qemu-system-x86_64 centos7-baremetal.raw -vnc :1 # netstat -plnt | grep 5901
```

```
# boot with kernel, initrd
qemu-system-x86_64 -nographic -kernel centos7-baremetal.vmlinuz -initrd centos7-baremetal.initrd -m 512 -append console=ttyS0
init 0

# boot with kernel, initrd, rootfs
qemu-system-x86_64 -nographic -kernel centos7-baremetal.vmlinuz -initrd centos7-baremetal.initrd -hda centos7-baremetal.raw -m 512 -append "root=/dev/sda console=ttyS0"
init 0

REF http://lockett.altervista.org/linuxboot/linuxboot.html

# Boot With initramfs
qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio -m 512
qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio -m 512 -append noapic
qemu-system-x86_64 -kernel bzImage -initrd initramfs.cpio -m 512 -nographic -append console=ttyS0
```

```
# v3.1
yum -y group install "Development Tools"
yum -y install python-devel
pip install python-openstackclient==3.2.1
pip install openstacksdk==0.9.5
pip install osc-lib==1.1.0
pip install keystoneauth1==2.12.3
pip install python-novaclient==6.0.0
pip install python-keystoneclient==3.5.0
pip install python-glanceclient==2.5.0
pip install python-cinderclient==1.9.0
pip install os-client-config==1.21.1
pip install python-neutronclient==6.0.0

openstack image delete bm-c7-k80
openstack image create --container-format bare --disk-format raw --unprotected --public --tag baremetal --file centos7-baremetal.raw bm-c7-k80
```

# Addiontional Resources

* https://docs.openstack.org/diskimage-builder/latest/
* create image https://docs.openstack.org/project-install-guide/baremetal/draft/configure-glance-images.html
* create image https://docs.openstack.org/image-guide/centos-image.html
* create image https://docs.openstack.org/image-guide/create-images-automatically.html
* modify image https://docs.openstack.org/image-guide/modify-images.html
* dib wrapper https://github.com/openstack/octavia/blob/master/diskimage-create/diskimage-create.sh
* nocloud http://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
* inject root password http://madorn.com/cloud-init-admin-pass.html#.Wn6wNJP1XBI
* inject root password http://blog.csdn.net/sinat_22597285/article/details/76981218
* inject root password https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/installation_and_configuration_guide/setting_up_cloud_init
* inject root password https://zhangchenchen.github.io/2017/01/13/openstack-init-instance-password/
* element of driver type https://github.com/openstack/diskimage-builder/tree/master/diskimage_builder/elements/mellanox
* DIB_BLOCK_DEVICE_CONFIG https://docs.openstack.org/diskimage-builder/latest/user_guide/building_an_image.html
* OVERWRITE_OLD_IMAGE https://docs.openstack.org/diskimage-builder/latest/developer/invocation.html
* DIB_OFFLINE https://docs.openstack.org/diskimage-builder/latest/developer/caches.html
* ELEMENTS_PATH https://docs.openstack.org/diskimage-builder/latest/developer/invocation.html
* Element Phase Subdirectories https://docs.openstack.org/diskimage-builder/latest/developer/developing_elements.html
* Element Dependencies https://docs.openstack.org/diskimage-builder/latest/developer/developing_elements.html
* sample install.d/99-ele https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/devuser/install.d/50-devuser
* sample environment.d/99-ele https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/devuser/environment.d/50-devuser
* sample download then install rpm https://github.com/openstack/diskimage-builder/blob/master/diskimage_builder/elements/proliant-tools/install.d/65-proliant-tools-install
* initrd initramfs rootfs http://blog.linux.org.tw/~jserv/archives/001954.html
* bootloader kernel initrd /dev/ram0 init mount rootfs chroot /sbin/init http://kezeodsnx.pixnet.net/blog/post/25371285-%E6%88%91%E4%B9%9F%E4%BE%86%E5%AF%ABinitrd
* initramfs http://nairobi-embedded.org/initramfs_tutorial.html
* qemu-system-x86_64 vnc https://www.cyberciti.biz/faq/linux-kvm-vnc-for-guest-machine/
* qemu-system-x86_64 vnc https://gnu-linux.org/creating-a-qemu-system-image-and-working-with-it-using-ssh-login.html
* cobbler distro add clonezilla vmlinuz initrd filesystem.squashfs http://cobbler.github.io/manuals/2.4.0/5/13_-_Clonezilla_Integration.html
* debootstrap https://github.com/KingBing/blog-src/blob/master/%E4%BD%BF%E7%94%A8%20debootstrap%20%E5%BB%BA%E7%AB%8B%E5%AE%8C%E6%95%B4%E7%9A%84%20Debian%20%E7%B3%BB%E7%B5%B1.org
* mksquashfs unsquashfs http://blog.xuite.net/ahdeng/life/19689236-%E8%AE%93Linux+Kernel%E6%94%AF%E6%8F%B4Squash+Filesystem
* mkisofs genisoimage http://linux-guys.blogspot.tw/2011/01/mkisofs-genisoimage.html
* cirros nocloud https://serverfault.com/questions/646326/how-do-i-disable-the-metadata-lookup-at-cirros-boot
* grub-probe http://edoceo.com/notabene/grub-probe-error-cannot-find-device-for-root
* make rootfs http://www.tldp.org/HOWTO/Bootdisk-HOWTO/buildroot.html

.

* http://docs.linuxtone.org/ebooks/Dell/ipmitool.pdf
* https://www.ibm.com/support/knowledgecenter/en/linuxonibm/liaai.ipmi/liaaiipmitoolsol.htm
* http://divideoverflow.com/2016/07/Configuring_IPMI_on_OVH_server/
* console tty ttys pty
* https://bimsj.idv.tw/blog/2016/08/07/linux-kvm%E7%9A%84-virsh-console-%E9%80%A3%E6%8E%A5%E8%99%9B%E6%93%AC%E6%A9%9F/
* https://wiki.archlinux.org/index.php/working_with_the_serial_console
* https://nfolamp.wordpress.com/2010/08/16/mounting-raw-image-files-and-kpartx/
* https://zh.wikipedia.org/wiki/Loop%E8%AE%BE%E5%A4%87
* http://handingsky.blogspot.tw/2012/02/kernel-initrd-root-filesystem.html
* http://www.tldp.org/HOWTO/Bootdisk-HOWTO/buildroot.html
