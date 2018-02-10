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
disk-image-create -t raw centos7 vm dhcp-all-interfaces grub2 enable-serial-console selinux-permissive devuser cloud-init-nocloud -o centos7-baremetal

# Build Option 2
export DIC_CLOUD_INIT_DATASOURCES="ConfigDrive"
disk-image-create -t raw centos7 vm dhcp-all-interfaces grub2 enable-serial-console selinux-permissive devuser openssh-server -o centos7-baremetal

# Build option 3


# cache dir: /root/.cache/image-create
# base image: http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz

yum -y install libguestfs-tools
yum -y install libvirt
service libvirtd start

# Inspect Method 1 :: [ virt-df ] 
export LIBGUESTFS_BACKEND=direct
virt-df -a centos7-baremetal.raw

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
kpartx -av /dev/loop0
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
# rm /etc/libvirt/qemu/cirros.xml
# virsh -c qemu:///system undefine cirros
```

# Addiontional Resources

* https://docs.openstack.org/diskimage-builder/latest/
* create image https://docs.openstack.org/image-guide/centos-image.html
* create image https://docs.openstack.org/image-guide/create-images-automatically.html
* modify image https://docs.openstack.org/image-guide/modify-images.html
* https://github.com/openstack/octavia/blob/master/diskimage-create/diskimage-create.sh
