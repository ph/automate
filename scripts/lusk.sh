#!/run/current-system/profile/bin/bash

# SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e
set -o pipefail


DISK1=nvme0n1

#dd if=/dev/zero of=/dev/$DISK1 bs=8M count=4
#cryptsetup open --type plain -d /dev/urandom /dev/$DISK1 to_be_wiped_1
#cryptsetup open --type plain -d /dev/urandom /dev/$DISK2 to_be_wiped_2
#dd if=/dev/zero of=/dev/mapper/to_be_wiped_1 bs=4M status=progress
#dd if=/dev/zero of=/dev/mapper/to_be_wiped_2 bs=4M status=progress
#cryptsetup close to_be_wiped_1
#cryptsetup close to_be_wiped_2

sgdisk --zap-all /dev/$DISK1

sgdisk -og /dev/$DISK1
sgdisk -n 1:0:+512M -t 1:EF00 /dev/$DISK1
sgdisk -n 2:0:0 -t 2:8300 /dev/$DISK1

# raid
mkdir -p /mnt/tmp
mkfs.btrfs -f -L root-fs /dev/${DISK1}p2
mount /dev/${DISK1}p2 /mnt/tmp
btrfs subvolume set-default $(btrfs subvolume list /mnt/tmp| awk '{print $2}') /mnt/tmp

btrfs subvol create /mnt/tmp/@
btrfs subvol create /mnt/tmp/@home
btrfs subvol create /mnt/tmp/@nix
btrfs subvol create /mnt/tmp/@log
btrfs subvol create /mnt/tmp/@gnu
btrfs subvol create /mnt/tmp/@swap

umount /mnt/tmp

mkfs.vfat -F32 /dev/${DISK1}p1

mkdir -p /mnt/newroot
mount -o subvol=@ /dev/${DISK1}p2 /mnt/newroot

mkdir -p /mnt/newroot/boot/efi
mkdir -p /mnt/newroot/home
mkdir -p /mnt/newroot/gnu
mkdir -p /mnt/newroot/nix
mkdir -p /mnt/newroot/etc
mkdir -p /mnt/newroot/tmp
mkdir -p /mnt/newroot/var/log
mkdir -p /mnt/newroot/.swap

mount -o subvol=@home /dev/${DISK1}p2 /mnt/newroot/home
mount -o subvol=@gnu /dev/${DISK1}p2 /mnt/newroot/gnu
mount -o subvol=@nix /dev/${DISK1}p2 /mnt/newroot/nix
mount -o subvol=@log /dev/${DISK1}p2 /mnt/newroot/var/log
mount -o subvol=@swap /dev/${DISK1}p2 /mnt/newroot/.swap
mount /dev/${DISK1}p1 /mnt/newroot/boot/efi

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
