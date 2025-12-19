#!/usr/bin/env bash

# Run this script from NixOS live ISO like this:
# $ curl -fsSL https://raw.githubusercontent.com/darkcodi/my-nixos-config/main/scripts/install.sh | bash

set -euo pipefail

REPO="https://github.com/darkcodi/my-nixos-config"
DIR="/tmp/nixos-config"

# Clone the repo if does not exist
if [ -d "$DIR/.git" ]; then
  echo "Repo already exists at $DIR, skipping clone"
else
  git clone --depth 1 "$REPO" "$DIR"
fi

# Add 8GB zram to prevent OOM during installation
sudo modprobe zram
echo $((8*1024*1024*1024)) | sudo tee /sys/block/zram0/disksize >/dev/null
sudo mkswap /dev/zram0
sudo swapon /dev/zram0

# Disable concurrency build to reduce RAM usage
# export NIX_CONFIG=$'max-jobs = 1\ncores = 1\n'

# Perform the installation
sudo nixos-install --root /mnt --flake $DIR#misato
