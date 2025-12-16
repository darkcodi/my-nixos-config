#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash coreutils git age alejandra

# Usage:
#   curl -fsSL https://raw.githubusercontent.com/darkcodi/my-nixos-config/refs/heads/main/bootstrap.sh | bash

set -euo pipefail

echo "=== NixOS Configuration Bootstrap ==="

echo "Cloning repository..."
git clone https://github.com/darkcodi/my-nixos-config.git
cd my-nixos-config

echo "Copying hardware configuration..."
sudo cp /etc/nixos/hardware-configuration.nix hosts/misato/hardware.nix

echo "Formatting configuration with alejandra..."
nix run nixpkgs#alejandra -- hosts/misato/hardware.nix

echo "Restoring agenix SSH keys..."
./secrets/restore_agenix_ssh_key.sh

echo "Rebuilding NixOS system..."
sudo nixos-rebuild switch --flake .#misato

echo "Updating git remote to SSH..."
git remote set-url origin git@github.com:darkcodi/my-nixos-config.git

echo "=== Bootstrapping complete! ==="
