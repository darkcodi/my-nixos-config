#!/usr/bin/env bash

set -euo pipefail

REPO="https://github.com/darkcodi/my-nixos-config"
DIR="/tmp/nixos-config"

# Clone the repo if does not exist
if [ -d "$DIR/.git" ]; then
  echo "Repo already exists at $DIR, skipping clone"
else
  git clone --depth 1 "$REPO" "$DIR"
fi

# Partition the disk
sudo nix ---extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko "$DIR/hosts/$HOST/disko.nix"
