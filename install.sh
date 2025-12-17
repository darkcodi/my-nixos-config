#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash coreutils gnugrep findutils util-linux cacert
#! nix-shell -I nixpkgs=flake:nixpkgs

set -euo pipefail

# Configuration
readonly HOSTNAME="misato"
readonly FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DISKO_CONFIG_TEMPLATE="${FLAKE_DIR}/hosts/${HOSTNAME}/disko.nix"
readonly DISKO_CONFIG_TMP="/tmp/disko-${HOSTNAME}.nix"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

warn() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Phase indicator
phase() {
    echo -e "\n${BLUE}>>>${NC} $1"
}

# Check if running as root
check_root() {
    phase "Checking prerequisites..."
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
    success "Running as root"
}

# Check for required files
check_files() {
    phase "Verifying configuration files..."
    if [[ ! -f "${FLAKE_DIR}/flake.nix" ]]; then
        error "flake.nix not found in ${FLAKE_DIR}"
        exit 1
    fi
    success "flake.nix found"

    if [[ ! -d "${FLAKE_DIR}/hosts/${HOSTNAME}" ]]; then
        error "Host directory not found: ${FLAKE_DIR}/hosts/${HOSTNAME}"
        exit 1
    fi
    success "Host configuration found: ${HOSTNAME}"

    if [[ ! -f "${DISKO_CONFIG_TEMPLATE}" ]]; then
        error "Disko configuration template not found: ${DISKO_CONFIG_TEMPLATE}"
        exit 1
    fi
    success "Disko configuration template found"
}

# Check for nix command
check_nix() {
    phase "Checking for Nix command..."
    if ! command -v nix &> /dev/null; then
        error "Nix command not found. This script must be run from a NixOS live environment."
        exit 1
    fi
    success "Nix command available"
}

# Show available disks
show_disks() {
    phase "Available disks on this system:"

    # Get list of disks
    local disks
    mapfile -t disks < <(lsblk -d -n -o NAME,SIZE,TYPE | awk '$3 == "disk" {print $1}')

    if [[ ${#disks[@]} -eq 0 ]]; then
        error "No disks found"
        exit 1
    fi

    echo ""
    echo "NAME    SIZE     TYPE"
    echo "────    ─────    ─────"
    for disk in "${disks[@]}"; do
        local size
        size=$(lsblk -d -n -o SIZE "/dev/${disk}")
        printf "%-8s %-8s %s\n" "${disk}" "${size}" "disk"
    done
    echo ""
}

# Get disk selection from user
get_disk_selection() {
    phase "Disk Selection"

    show_disks

    local disk_selected=""
    while [[ -z "$disk_selected" ]]; do
        echo "Enter the disk device name (e.g., 'sda', 'nvme0n1') or full path:"
        read -r -p "> " disk_input

        # Handle full path or just device name
        if [[ "$disk_input" =~ ^/dev/ ]]; then
            if [[ -b "$disk_input" ]]; then
                disk_selected="$disk_input"
            else
                error "Device not found: $disk_input"
            fi
        else
            if [[ -b "/dev/${disk_input}" ]]; then
                disk_selected="/dev/${disk_input}"
            else
                error "Device not found: /dev/${disk_input}"
            fi
        fi
    done

    echo ""
    warn "You have selected: $disk_selected"
    echo ""
    echo "WARNING: This will ERASE ALL DATA on ${disk_selected}!"
    echo ""
    read -p "Type 'yes' to continue: " -r
    echo ""

    if [[ ! $REPLY =~ ^yes$ ]]; then
        info "Installation cancelled by user"
        exit 0
    fi

    DISK_DEVICE="$disk_selected"
    success "Selected disk: ${DISK_DEVICE}"
}

# Generate disko configuration with selected disk
generate_disko_config() {
    phase "Generating disko configuration..."

    # Create disko config with the selected disk
    cat > "${DISKO_CONFIG_TMP}" << EOF
{...}: {
  imports = [
    ${DISKO_CONFIG_TEMPLATE}
  ];

  diskoConfig.device = "${DISK_DEVICE}";
}
EOF

    success "Disko configuration generated: ${DISKO_CONFIG_TMP}"
}

# Get LUKS password from user
get_luks_password() {
    phase "LUKS Encryption Setup"

    echo "You will now set the LUKS encryption password."
    echo "This password will be required to unlock your disk on every boot."
    echo ""

    local password1=""
    local password2=""

    while true; do
        read -s -p "Enter LUKS password: " password1
        echo ""
        read -s -p "Confirm LUKS password: " password2
        echo ""

        if [[ -z "$password1" ]] || [[ -z "$password2" ]]; then
            error "Password cannot be empty. Please try again."
            continue
        fi

        if [[ "$password1" != "$password2" ]]; then
            error "Passwords do not match. Please try again."
            continue
        fi

        LUKS_PASSWORD="$password1"
        break
    done

    success "LUKS password set"
}

# Run disko to partition and format disk
run_disko() {
    phase "Running disko - partitioning and formatting disk..."

    # Run disko with the generated config
    # The password is provided via stdin
    if ! echo "${LUKS_PASSWORD}" | nix run \
        --experimental-features "nix-command flakes" \
        github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        "${DISKO_CONFIG_TMP}"; then
        error "Disko failed to partition and format the disk"
        cleanup_on_error
        exit 1
    fi

    success "Disk partitioned and formatted successfully"
}

# Generate NixOS hardware configuration
generate_hardware_config() {
    phase "Generating NixOS hardware configuration..."

    if ! nixos-generate-config --no-filesystems --root /mnt; then
        error "Failed to generate hardware configuration"
        cleanup_on_error
        exit 1
    fi

    success "Hardware configuration generated"
}

# Copy configuration to /mnt
copy_config() {
    phase "Copying NixOS configuration to /mnt/etc/nixos/..."

    # Ensure target directory exists
    mkdir -p /mnt/etc/nixos

    # Copy all configuration files
    if ! cp -r "${FLAKE_DIR}"/* /mnt/etc/nixos/; then
        error "Failed to copy configuration files"
        cleanup_on_error
        exit 1
    fi

    success "Configuration files copied"
}

# Install NixOS
install_nixos() {
    phase "Installing NixOS..."

    cd /mnt/etc/nixos

    if ! nixos-install --flake ".#${HOSTNAME}"; then
        error "NixOS installation failed"
        error "Check /mnt/log for installation logs"
        cleanup_on_error
        exit 1
    fi

    success "NixOS installed successfully"
}

# Cleanup function for errors
cleanup_on_error() {
    error "Cleaning up temporary files..."
    if [[ -f "${DISKO_CONFIG_TMP}" ]]; then
        rm -f "${DISKO_CONFIG_TMP}"
    fi
}

# Cleanup function for success
cleanup_success() {
    info "Cleaning up temporary files..."
    if [[ -f "${DISKO_CONFIG_TMP}" ]]; then
        rm -f "${DISKO_CONFIG_TMP}"
    fi
    # Clear password from memory
    if [[ -n "${LUKS_PASSWORD:-}" ]]; then
        unset LUKS_PASSWORD
    fi
}

# Show post-install instructions
show_instructions() {
    echo ""
    echo "================================================================"
    success "Installation Complete!"
    echo "================================================================"
    echo ""
    echo "Your NixOS system has been installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Reboot the system: reboot"
    echo "  2. Set a root password: sudo passwd"
    echo "  3. Create your user account (if needed)"
    echo "  4. Start using NixOS!"
    echo ""
    echo "Configuration location: /etc/nixos/"
    echo "Repository location: /root/config/"
    echo ""
    echo "To make changes to your configuration, edit files in /etc/nixos/"
    echo "and run: sudo nixos-rebuild switch --flake /etc/nixos/"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "================================================================"
    echo "              NixOS Installation Script"
    echo "================================================================"
    echo ""
    echo "This script will install NixOS with the following configuration:"
    echo "  - Hostname: ${HOSTNAME}"
    echo "  - Filesystem: Btrfs with subvolumes"
    echo "  - Encryption: LUKS"
    echo "  - Boot: systemd-boot"
    echo ""
    echo "================================================================"
    echo ""

    # Run installation phases
    check_root
    check_files
    check_nix
    get_disk_selection
    generate_disko_config
    get_luks_password
    run_disko
    generate_hardware_config
    copy_config
    install_nixos
    cleanup_success
    show_instructions
}

# Run main function
main "$@"
