#!/usr/bin/env bash

# Run this script from NixOS live ISO like this:
# $ curl -fsSL https://raw.githubusercontent.com/darkcodi/my-nixos-config/main/scripts/partition.sh | bash

set -euo pipefail

REPO="https://github.com/darkcodi/my-nixos-config"
DIR="/tmp/nixos-config"
HOST="misato"

# Clone the repo if does not exist
if [ -d "$DIR/.git" ]; then
  echo "Repo already exists at $DIR, skipping clone"
else
  git clone --depth 1 "$REPO" "$DIR"
fi

# Partition the disk
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko "$DIR/hosts/$HOST/disko.nix"
