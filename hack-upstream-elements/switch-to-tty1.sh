sed -i 's/tty0/tty1/g' /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
sed -i 's/ttyS0/ttyS1/g' /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
