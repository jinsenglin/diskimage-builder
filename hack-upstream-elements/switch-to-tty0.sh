sed -i 's/tty1/tty0/g' /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
sed -i 's/ttyS1/ttyS0/g' /usr/lib/python2.7/site-packages/diskimage_builder/elements/bootloader/finalise.d/50-bootloader
