#!/usr/bin/env bash
# Generate swupdate file (.swu).
#
# Example from https://sbabic.github.io/swupdate/swupdate.html:
#
# CONTAINER_VER="1.0"
# PRODUCT_NAME="my-software"
# FILES="sw-description image1.ubifs  \
# 	       image2.gz.u-boot uImage.bin myfile sdcard.img"
# for i in $FILES;do
# 	        echo $i;done | cpio -ov -H crc >  ${PRODUCT_NAME}_${CONTAINER_VER}.swu
#
# Run swupdate webserver:
#  $ swupdate -w "-document_root /var/www/swupdate"
#
# Or install local file:
#  $ swupdate -i FILE.swu

# To "toggle" the installation destination with swupdate, create a
# sw-description file that duplicates two images under two different names
# (part1/part2) and then invoke swupdate with --select <software>,<mode> flag
# (which can be selected appropriately based on U-Boot env vars, or by looking
# at what partition we're currently running from. E.g.
#
#  sed 's|.*root=/dev/mmcblk2p\(.\).*|\1|' /proc/cmdline
#
# Example:
#  swupdate -v --select stable,part1 -i /tmp/my-software_0.1.swu

# Run in <buildroot>/output/images/, so that we can use plain file names (no
# sub-directories) in file paths. Without this, swupdate (webserver mode) seems
# to choke on our .swu files. swupdate CLI handles it fine though.
if [ "${BINARIES_DIR}" = "" ]; then
	echo "ERROR: \$BINARIES_DIR is empty. If you're running outside of Buildroot, please set \$BINARIES_DIR to the root where the image files are."
	exit 1
fi
cd "${BINARIES_DIR}"

CONTAINER_VER="0.1"
PRODUCT_NAME="my-software"
FILES="
sw-description
rootfs.ext2
"
# Are sub-paths troublesome? E.g. output/images/rootfs.ext2? Possibly the
# WebUI, but "swupdate -i FILE" seems to handle it.

cat > sw-description << EOF
software =
{
    version = "0.1";

    stable:
    {
        part1:
        {
            images: (
            {
                filename = "rootfs.ext2";
                device = "/dev/mmcblk2p1";
                type = "raw";
            }
            );

            uboot: (
            {
                name = "mmcpart";
                value = "1";
            }
            );
        };

        part2:
        {
            images: (
            {
                filename = "rootfs.ext2";
                device = "/dev/mmcblk2p2";
                type = "raw";
            }
            );

            uboot: (
            {
                name = "mmcpart";
                value = "2";
            }
            );
        };
    };
}
EOF

result=${PRODUCT_NAME}_${CONTAINER_VER}.swu
echo "### Creating swupdate file: $result"
for i in $FILES; do
	echo $i
done | cpio -ov -H crc > $result
echo "...done"

# Robustness test
#echo "Intentionally corrupting $result"
#dd if=/dev/urandom of=$result bs=1 seek=17600000 count=1 conv=notrunc
