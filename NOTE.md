Images are built using a `chroot` and `bind mounted /proc /sys and /dev`.

Source: https://docs.openstack.org/diskimage-builder/latest/developer/design.html

---

```
{BIOS , UEFI} :: POST
    CHOOSE BOOT DEVICE {CD-ROM, HDD, NETWORK} :: LOCATE {MBR, BOOT SECTOR} :: LOAD BOOT LOADER

BOOT LOADER {LILO, GRUB, GRUB2, PXELINUX, SYSLINUX, ISOLINUX, EXTLINUX} :: LOAD KERNEL

KERNEL {VMLINUX, VMLINUZ, INITRD, INITRAMFS} :: CHANGE ROOTFS AND RUN INIT

init {sysvinit, upstart, systemd}
```
