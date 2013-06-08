#!/bin/sh
set -x
qemu-system-arm -M versatilepb -kernel output/images/zImage -hda output/images/rootfs.ext2 -append "root=/dev/sda console=ttyAMA0,115200" -serial stdio
