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
# build
# - tty0
# - unset ConfigDrive
disk-image-create -t raw centos7 vm selinux-permissive devuser cloud-init-nocloud -o centos7-baremetal

# launch
virt-install --connect=qemu:///system --name=centos7 --ram=512 --vcpus=1 --disk path=centos7-baremetal.raw,format=raw --import --network network:default --vnc

# about /cloud-init-once.sh
cat > /cloud-init-once.sh <<DATA
#!/bin/bash
date >> /tmp/cloud-init-once.log
DATA

# about /var/lib/cloud/seed/nocloud/user-data
cat > /var/lib/cloud/seed/nocloud/user-data <<DATA
#cloud-config
bootcmd:
 - echo 192.168.1.130 us.archive.ubuntu.com >> /etc/hosts
 - [ cloud-init-per, once, my-init-once, /cloud-init-once.sh ]
DATA

# hack 1 :: /etc/cloud/cloud.cfg

# hack 2 :: /var/lib/cloud/instance/cloud-config.txt
cat > /var/lib/cloud/instance/cloud-config.txt <<DATA
#cloud-config

# from 1 files
# part-001

---
bootcmd:
- echo 192.168.1.133 us.archive.ubuntu.com >> /etc/hosts
-   - cloud-init-per
    - always
    - my-init-once
    - /cloud-init-once.sh
...
DATA

# hack 3 :: /usr/lib/python2.7/site-packages/cloudinit/config/cc_bootcmd.py
#
# def handle(name, cfg, cloud, log, _args):
#     log.error(cfg['bootcmd'])
#

# cloud-init init
cloud-init single --name bootcmd
#
# Cloud-init v. 0.7.9 running 'single' at Wed, 21 Feb 2018 07:52:51 +0000. Up 796.07 seconds.
# 2018-02-21 07:52:52,661 - cc_bootcmd.py[ERROR]: ['echo 192.168.1.133 us.archive.ubuntu.com >> /etc/hosts', ['cloud-init-per', 'always', 'my-init-once', '/cloud-init-once.sh']]
#

cat /etc/hosts
cat /tmp/cloud-init-once.log
```

Additional Resources

* https://cloudinit.readthedocs.io/en/latest/topics/capabilities.html#cli-interface
* https://cloudinit.readthedocs.io/en/latest/topics/modules.html#bootcmd
* https://cloudinit.readthedocs.io/en/latest/topics/examples.html#run-commands-on-first-boot
