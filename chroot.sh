#!/bin/bash

sudo -i
cryptsetup open /dev/sda2 cryptroot
mount /dev/mapper/cryptroot /mnt
mount /dev/sda1 /mnt/@/boot
nixos-enter --root /mnt/@
