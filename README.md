yum -y install epel-release
yum -y update
yum -y install python-pip

pip install diskimage-builder
yum -y install qemu-img
DIC_CLOUD_INIT_DATASOURCES="ConfigDrive" disk-image-create -t raw centos7 vm dhcp-all-interfaces -o centos7-baremetal

yum -y install libguestfs-tools
yum -y install libvirt
service libvirtd start

virt-df -a centos7-baremetal.raw
