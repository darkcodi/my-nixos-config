# Main system configuration for the 'misato' host
{
  pkgs,
  lib,
  username,
  ...
}: {
  # Import host-specific configurations
  imports = [
    ./hardware.nix # Hardware-specific kernel modules and settings
    ./impermanence.nix # Ephemeral root with selective persistence

    # System-level configurations
    ../../system/security.nix # Security settings (firewall, sudo, etc.)
    ../../system/performance.nix # Performance tuning and resource limits
    ../../system/swap.nix # ZRAM swap and memory management
    ../../system/power-management.nix # Power/sleep settings (system never sleeps)
    ../../system/locale.nix # Locale, timezone, and keyboard settings
    ../../system/journald.nix # Journal logging with automatic cleanup
    ../../system/nix.nix # Nix package manager settings (binary cache, GC, etc.)
    ../../system/bootloader.nix # Boot loader and kernel parameters
    ../../system/user-management.nix # User and group definitions
    ../../system/tailscale.nix # Tailscale VPN service

    # Application configurations
    ../../apps/gnome.nix # GNOME desktop environment
    ../../apps/mosh.nix # Mosh (mobile shell) for SSH connections
    ../../apps/rclone-mega.nix # Rclone MEGA cloud storage mount
    ../../apps/gui-runtime-deps.nix # Common GUI runtime libraries (webkitgtk, gtk3, etc.)

    # Secrets management
    ../../secrets/system-decrypt.nix # Agenix secret decryption setup
  ];

  # System identity
  networking.hostName = "misato";
  networking.networkmanager.enable = true; # NetworkManager for Wi-Fi and Ethernet

  # Default shell
  programs.zsh.enable = true;

  # NixOS version (DO NOT CHANGE - used for migrations)
  system.stateVersion = "25.11";
}
