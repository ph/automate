#!/run/current-system/profile/bin/bash

# SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e
set -o pipefail

PASSWORD="<PASSWORD>"

DISK1=nvme0n1
DISK2=nvme1n1

#dd if=/dev/zero of=/dev/$DISK1 bs=8M count=4
#dd if=/dev/zero of=/dev/$DISK2 bs=8M count=4
#cryptsetup open --type plain -d /dev/urandom /dev/$DISK1 to_be_wiped_1
#cryptsetup open --type plain -d /dev/urandom /dev/$DISK2 to_be_wiped_2
#dd if=/dev/zero of=/dev/mapper/to_be_wiped_1 bs=4M status=progress
#dd if=/dev/zero of=/dev/mapper/to_be_wiped_2 bs=4M status=progress
#cryptsetup close to_be_wiped_1
#cryptsetup close to_be_wiped_2

sgdisk --zap-all /dev/$DISK1
sgdisk --zap-all /dev/$DISK2

sgdisk -og /dev/$DISK1
sgdisk -n 1:0:+512M -t 1:EF00 /dev/$DISK1
sgdisk -n 2:0:+100G -t 2:8300 /dev/$DISK1
sgdisk -n 3:0:+1G -t 3:8300 /dev/$DISK1
sgdisk -n 4:0:0 -t 4:8300 /dev/$DISK1

sgdisk -og /dev/$DISK2
sgdisk -n 1:0:0 -t 1:8300 /dev/$DISK2

sgdisk -G /dev/$DISK1
sgdisk -G /dev/$DISK2

# disk 1
echo -n $PASSWORD | cryptsetup luksFormat /dev/${DISK1}p2 -
echo -n $PASSWORD | cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue /dev/${DISK1}p2 cryptsys

echo -n $PASSWORD | cryptsetup luksFormat /dev/${DISK1}p3 -
echo -n $PASSWORD | cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue /dev/${DISK1}p3 cryptboot

echo -n $PASSWORD | cryptsetup luksFormat /dev/${DISK1}p4 -
echo -n $PASSWORD | cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue /dev/${DISK1}p4 cryptroot-1

# disk 2
echo -n $PASSWORD | cryptsetup luksFormat /dev/${DISK2}p1 -
echo -n $PASSWORD | cryptsetup open --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue /dev/${DISK2}p1 cryptroot-2


# raid
mkdir -p /mnt/cryptroot
mkfs.btrfs -f -L root-fs -d raid0 -m raid0 /dev/mapper/cryptroot-1 /dev/mapper/cryptroot-2
mount /dev/mapper/cryptroot-1 /mnt/cryptroot/
btrfs subvolume set-default $(btrfs subvolume list /mnt/cryptroot | awk '{print $2}') /mnt/cryptroot

btrfs subvol create /mnt/cryptroot/@
btrfs subvol create /mnt/cryptroot/@home
btrfs subvol create /mnt/cryptroot/@ph
btrfs subvol create /mnt/cryptroot/@nix
btrfs subvol create /mnt/cryptroot/@log
btrfs subvol create /mnt/cryptroot/@gnu

umount /mnt/cryptroot

mkfs.vfat -F32 /dev/${DISK1}p1

mkdir -p /mnt/newroot
mount -o subvol=@ /dev/mapper/cryptroot-1 /mnt/newroot

# boot
mkdir -p /mnt/boot
mkfs.btrfs -f -L boot-fs /dev/mapper/cryptboot
mount /dev/mapper/cryptboot /mnt/boot
btrfs subvol create /mnt/boot/@boot
umount /mnt/boot

mkdir -p /mnt/newroot/boot/
mount -o subvol=@boot /dev/mapper/cryptboot /mnt/newroot/boot

mkdir -p /mnt/newroot/boot/efi
mkdir -p /mnt/newroot/boot/keys
mkdir -p /mnt/newroot/home
mkdir -p /mnt/newroot/gnu
mkdir -p /mnt/newroot/nix
mkdir -p /mnt/newroot/etc
mkdir -p /mnt/newroot/tmp
mkdir -p /mnt/newroot/var/log

mount -o subvol=@home /dev/mapper/cryptroot-1 /mnt/newroot/home
mkdir -p /mnt/newroot/home/ph
mount -o subvol=@ph /dev/mapper/cryptroot-1 /mnt/newroot/home/ph
mount -o subvol=@gnu /dev/mapper/cryptroot-1 /mnt/newroot/gnu
mount -o subvol=@nix /dev/mapper/cryptroot-1 /mnt/newroot/nix
mount -o subvol=@log /dev/mapper/cryptroot-1 /mnt/newroot/var/log
mount /dev/${DISK1}p1 /mnt/newroot/boot/efi

# swap
mkdir -p /mnt/sys
mkfs.btrfs -f -L sys-fs /dev/mapper/cryptsys
mount /dev/mapper/cryptsys /mnt/sys/
btrfs subvol create /mnt/sys/@swap
umount /mnt/sys

mkdir -p /mnt/newroot/.swap
mount -o subvol=@swap /dev/mapper/cryptsys /mnt/newroot/.swap

# cp /etc/channels.scm /mnt/newroot/etc
# cp config.scm /mnt/newroot/etc
# chmod +w /mnt/newroot/etc/config.scm
# check uuid and id of the other drive
# cryptsetup luksUUID /dev/nvm*
# blkid
# herd start cow-store /mnt/newroot

# guix time-machine -C /mnt/newroot/etc/channels.scm -- system init /mnt/newroot/etc/config.scm /mnt/newroot

# Procedure: luks-device-mapping-with-options [#:key-file #:allow-discards?]

# $ sudo dd if=/dev/urandom of=/key-file.bin bs=512 count=8
# 8+0 records in
# 8+0 records out
# 4096 bytes (4.1 kB, 4.0 KiB) copied, 0.000631541 s, 6.5 MB/s
