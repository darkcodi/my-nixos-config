#!/usr/bin/env bash

# Run this script from NixOS live ISO like this:
# $ curl -fsSL https://raw.githubusercontent.com/darkcodi/my-nixos-config/main/scripts/post-install.sh | bash

set -euo pipefail

# chroot
sudo -i
cryptsetup open /dev/sda2 cryptroot
mount /dev/mapper/cryptroot /mnt
mount /dev/sda1 /mnt/@/boot
nixos-enter --root /mnt/@
su darkcodi

cd /home/darkcodi
git clone "https://github.com/darkcodi/my-nixos-config"
cd my-nixos-config/secrets
./restore_agenix_ssh_key.sh
cd ..
git remote set-url origin "git@github.com:darkcodi/my-nixos-config.git"
exit
exit
echo "Git repo clonned!"
