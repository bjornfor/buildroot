#!/usr/bin/env bash

cat > "${TARGET_DIR}/etc/fw_env.config" << EOF
# Block device example
/dev/mmcblk2       0x60000     0x2000
EOF

cat > "${TARGET_DIR}/etc/init.d/S60swupdate" << EOF
#!/bin/sh
#
# Starts swupdate (with webserver).
#

start() {
	printf "Starting swupdate: "
	cur_mmcpart=\$(sed 's|.*root=/dev/mmcblk2p\(.\).*|\1|' /proc/cmdline)
	if [ \$cur_mmcpart -eq 1 ]; then
		part=part2
	else
		part=part1
	fi
	swupdate -v --select stable,\$part -w "-document_root /var/www/swupdate" &
	echo OK
}

stop() {
	printf "Stopping swupdate: "
	killall swupdate
	echo OK
}

case "\$1" in
  start)
  	start
	;;
  stop)
  	stop
	;;
  *)
	echo "Usage: \$0 {start|stop}"
	exit 1
esac

exit $?
EOF
chmod +x "${TARGET_DIR}/etc/init.d/S60swupdate"


cat > "${TARGET_DIR}/usr/bin/safe-update" << EOF
#!/bin/sh
if [ "\$1" = "" ]; then
	echo "Usage: \$0 FILE.swu"
	exit 1
fi
cur_mmcpart=\$(sed 's|.*root=/dev/mmcblk2p\(.\).*|\1|' /proc/cmdline)
if [ \$cur_mmcpart -eq 1 ]; then
	part=part2
	new_mmcpart=2
else
	part=part1
	new_mmcpart=1
fi

#swupdate -v --select stable,\$part -i "\$1" && fw_setenv mmcpart \$new_mmcpart
#echo "### U-Boot environment manually set: fw_setenv mmcpart \$new_mmcpart"

# With swupdate @ git HEAD, it knows how to update U-Boot env vars in block
# devices too:
swupdate -v --select stable,\$part -i "\$1"
ret=\$?
if [ \$ret -eq 0 ]; then
	echo "### Update successful, rebooting in 5 seconds (unless aborted with Ctrl-C)."
	sleep 5
	reboot
fi
EOF
chmod +x "${TARGET_DIR}/usr/bin/safe-update"
