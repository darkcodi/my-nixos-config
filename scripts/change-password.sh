#!/usr/bin/env bash
set -euo pipefail

# Simple password change script
USERNAME="${1:-darkcodi}"

# Find config dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Generate hash and update age file
read -rs -p "New password: " PASSWORD
HASH=$(mkpasswd -m yescrypt "$PASSWORD")
echo -n "$HASH" | age -e -a -R "$CONFIG_DIR/secrets/agenix_ssh_key.pub" > "$CONFIG_DIR/secrets/age-files/${USERNAME}-password.age"

echo "✅ Done"
