#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash age coreutils

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIV_KEY_SRC="${SCRIPT_DIR}/age-files/agenix_ssh_key.age"
PUB_KEY_SRC="${SCRIPT_DIR}/agenix_ssh_key.pub"
SSH_DIR="${HOME}/.ssh"
PRIV_KEY_DST="${SSH_DIR}/agenix_ssh_key"
PUB_KEY_DST="${SSH_DIR}/agenix_ssh_key.pub"

if [[ -f "${PRIV_KEY_DST}" ]]; then
    echo "SSH key already exists: ${PRIV_KEY_DST}"
    echo "Aborting to avoid overwrite. Remove the file first if you want to replace it."
    exit 1
fi

mkdir -p "${SSH_DIR}"

echo "Decrypting agenix SSH privkey..."
age -d -o "${PRIV_KEY_DST}" "${PRIV_KEY_SRC}"

if [[ -f "${PUB_KEY_SRC}" ]]; then
    echo "Copying agenix SSH pubkey..."
    cp "${PUB_KEY_SRC}" "${PUB_KEY_DST}"
fi

echo "Agenix SSH key restored to: ${PRIV_KEY_DST}"
