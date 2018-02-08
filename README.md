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

export LIBGUESTFS_BACKEND=direct
virt-df -a centos7-baremetal.raw

#guestmount -a centos7-baremetal.raw -m /dev/sda1 --rw /tmp/tmp-img/
#mount --bind /dev /tmp/tmp-img/dev

#cd /tmp
#chroot tmp-img/
#PATH==$PATH:/bin
#mount -t proc proc /proc
#mount -t sysfs sys sys/
```
