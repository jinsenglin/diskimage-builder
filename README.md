```
yum -y install epel-release
yum -y update
yum -y install python-pip

pip install diskimage-builder
yum -y install qemu-img
DIC_CLOUD_INIT_DATASOURCES="ConfigDrive" disk-image-create -t raw centos7 vm dhcp-all-interfaces -o centos7-baremetal

yum -y install libguestfs-tools
yum -y install libvirt
service libvirtd start

# [ virt-df ] 
export LIBGUESTFS_BACKEND=direct
virt-df -a centos7-baremetal.raw

# [ guestfish ]
#export LIBGUESTFS_BACKEND=direct
#guestfish --ro -a centos7-baremetal.raw
#run
#list-filesystems
#exit

# [ virt-edit ]
#export LIBGUESTFS_BACKEND=direct
#virt-edit -a centos7-baremetal.raw /etc/hosts

# [ guestmount ]
#export LIBGUESTFS_BACKEND=direct
#guestmount -a centos7-baremetal.raw -m /dev/sda1 --ro /mnt
#ls /mnt
#umount /mnt

# [ guestmount ] + [ chroot ]

#guestmount -a centos7-baremetal.raw -m /dev/sda1 --rw /tmp/tmp-img/
#mount --bind /dev /tmp/tmp-img/dev

#cd /tmp
#chroot tmp-img/
#PATH==$PATH:/bin
#mount -t proc proc /proc
#mount -t sysfs sys sys/

#mount --bind /proc /target/proc
#mount --bind /dev /target/dev
#mount --bind /sys /target/sys
#chroot /target

# [ losetup ] + [ kpartx ]
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

# Addiontional Resources

* create image https://docs.openstack.org/image-guide/centos-image.html
* create image https://docs.openstack.org/image-guide/create-images-automatically.html
* modify image https://docs.openstack.org/image-guide/modify-images.html
