#!/bin/sh

logger "Add USB drive as extroot:"
        
logger "STEP 1: Configuring rootfs_data."
DEVICE="$(sed -n -e "/\s\/overlay\s.*$/s///p" /etc/mtab)"
uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${DEVICE}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

logger "STEP 2: Configuring extroot."
eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")
uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"
uci commit fstab

logger "STEP 3: Transferring data."
mkdir -p /tmp/cproot
mount --bind /overlay /tmp/cproot
mount ${DEVICE} /mnt
tar -C /tmp/cproot -cvf - . | tar -C /mnt -xf - 
umount /tmp/cproot /mnt

logger "Extoot configuration completed!."
logger "Don't forget to reboot the device!."
