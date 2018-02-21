Images are built using a `chroot` and `bind mounted /proc /sys and /dev`.

Source: https://docs.openstack.org/diskimage-builder/latest/developer/design.html

---

```
{BIOS, UEFI} :: POST
    CHOOSE BOOT DEVICE {CD-ROM, HDD, NETWORK} :: LOCATE {MBR, GPT, BOOT SECTOR} :: LOAD BOOT LOADER

BOOT LOADER {LILO, GRUB, GRUB2, PXELINUX, SYSLINUX, ISOLINUX, EXTLINUX} :: LOAD KERNEL

KERNEL {VMLINUX, VMLINUZ, INITRD, INITRAMFS} :: CHANGE ROOTFS AND RUN INIT

init {sysvinit, upstart, systemd}
```

---

在 boot loader 中指定 kernel , initrd , 以及 rootfs e.g.,

```
KERNEL=vmlinuz-2.6.32-5-686
INITRD=initrd.img-2.6.32-5-686
APPEND="root=/dev/sda2 ro "
IMG=qemu.img
qemu -kernel $KERNEL -initrd $INITRD -append "$APPEND"  -hda $IMG
```

Additional Resources

* kernel boot parameter https://wiki.archlinux.org/index.php/kernel_parameters

---

Each module is gated to run only once due to semaphores in `/var/lib/cloud/`.

Source: https://cloudinit.readthedocs.io/en/latest/topics/capabilities.html#cloud-init-modules

---

develop cloud-init

```
disk-image-create -t raw centos7 vm selinux-permissive devuser cloud-init-nocloud -o centos7-baremetal

virt-install --connect=qemu:///system --name=centos7 --ram=512 --vcpus=1 --disk path=centos7-baremetal.raw,format=raw --import --network network:default --vnc

cat > /var/lib/cloud/seed/nocloud/user-data <<DATA
#cloud-config
bootcmd:
 - echo 192.168.1.130 us.archive.ubuntu.com >> /etc/hosts
 - [ cloud-init-per, once, mymkfs, mkfs, /dev/vdb ]
DATA

# hack /usr/lib/python2.7/site-packages/cloudinit/config/cc_bootcmd.py

cloud-init single --name bootcmd
```

Additional Resources

* https://cloudinit.readthedocs.io/en/latest/topics/capabilities.html#cli-interface
* https://cloudinit.readthedocs.io/en/latest/topics/modules.html#bootcmd
* https://cloudinit.readthedocs.io/en/latest/topics/examples.html#run-commands-on-first-boot
