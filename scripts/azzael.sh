#!/bin/bash
# SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e
set -p pipefail
set -o xtrace

DISK1=sda
DISK2=sdb

parted --script /dev/$DISK1 \
       mklabel gpt \
       mkpart primary fat32 1MiB 512MiB \
       mkpart primary linux-swap 512Mib 64GiB \
       mkpart primary btrfs 64GiB 100%

parted --script /dev/$DISK2 \
       mklabel gpt \
       mkpart primary fat32 1MiB 512MiB \
       mkpart primary linux-swap 512Mib 64GiB \
       mkpart primary btrfs 64GiB 100% 

mkfs.btrfs -f -L root-fs --data raid1 --metadata raid1 /dev/${DISK1}3 /dev/${DISK2}3
mount /dev/${DISK1}3 /mnt

btrfs subvolume set-default $(btrfs subvolume list /mnt/ | awk '{print $2}') /mnt/

btrfs subvol create /mnt/@
btrfs subvol create /mnt/@home
btrfs subvol create /mnt/@log
btrfs subvol create /mnt/@gnu
btrfs subvol create /mnt/@snapshots

umount /mnt

mkfs.vfat -F32 /dev/${DISK1}1
mkfs.vfat -F32 /dev/${DISK2}1

mount -o subvol=@ /dev/${DISK1}3 /mnt
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mkdir -p /mnt/gnu
mkdir -p /mnt/etc
mkdir -p /mnt/tmp
mkdir -p /mnt/.snapshots
mkdir -p /mnt/var/log

mount -o subvol=@home /dev/${DISK1}3 /mnt/home
mount -o subvol=@gnu /dev/${DISK1}3 /mnt/gnu
mount -o subvol=@log /dev/${DISK1}3 /mnt/var/log
mount -o subvol=@snapshots /dev/${DISK1}3 /mnt/.snapshots
mount /dev/${DISK1}1 /mnt/boot/efi


mkswap /dev/${DISK1}2
swapon -p 10 /dev/${DISK1}2

mkswap /dev/${DISK2}2
swapon -p 5 /dev/${DISK2}2
