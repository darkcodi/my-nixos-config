#!/bin/bash
set -euo pipefail

sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries \
  --flake github:darkcodi/my-nixos-config#misato \
  --disk main /dev/disk/by-path/pci-0000:00:17.0-ata-2
