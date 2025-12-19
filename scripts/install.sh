#!/usr/bin/env bash

# Run this script from NixOS live ISO like this:
# $ curl -fsSL https://raw.githubusercontent.com/darkcodi/my-nixos-config/main/install.sh | bash

set -euo pipefail

# Add 10GB zram to prevent OOM during installation
sudo modprobe zram
echo $((10*1024*1024*1024)) | sudo tee /sys/block/zram0/disksize >/dev/null
sudo mkswap /dev/zram0
sudo swapon /dev/zram0

# Disable concurrency build to reduce RAM usage
export NIX_CONFIG=$'max-jobs = 1\ncores = 1\n'

# Increase writable store tmpfs size
sudo mount -o remount,size=10G,noatime /nix/.rw-store

sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake github:darkcodi/my-nixos-config#misato \
  --disk main /dev/disk/by-path/pci-0000:00:17.0-ata-2
