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
