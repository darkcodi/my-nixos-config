# ============================================================================
# IMPERMANENCE CONFIGURATION
# ============================================================================
# This file implements an ephemeral root filesystem with selective persistence.
#
# Architecture:
# - Root filesystem (/) is wiped on every boot → clean, predictable system state
# - Persistent storage (/persistent) survives reboots → important data preserved
# - Impermanence bind-mounts specific paths from /persistent into the root
#
# Benefits:
# - System state is always clean and reproducible
# - Forces explicit decisions about what data to persist
# - Prevents "it only works on my machine" issues from accumulated state
# - Easy to reset system to clean state by rebooting
# - All critical data must be explicitly declared in this file
#
# Key concepts:
# - neededForBoot: /persistent must be mounted before root switch
# - hideMounts: bind mounts are hidden (avoids confusing duplicates)
# - users.${username}: user-specific persistence (automatic home directory paths)
# ============================================================================
{
  lib,
  config,
  username,
  ...
}: {
  # ============================================================================
  # PERSISTENT FILESYSTEM MOUNT
  # ============================================================================
  # Mount the @persistent subvolume to /persistent
  # This is the source directory for all bind mounts below
  #
  # Note: disko.nix creates the subvolume, we just need to mount it here
  # Required: neededForBoot = true (impermanence needs this before root switch)
  # ============================================================================
  fileSystems."/persistent" = {
    device = "/dev/mapper/luks-root";
    fsType = "btrfs";
    options = ["subvol=@persistent"];
    neededForBoot = true; # Critical: impermanence runs before root is mounted
  };

  # ============================================================================
  # SYSTEM-LEVEL PERSISTENCE
  # ============================================================================
  # Bind mounts from /persistent into the root filesystem
  # These paths are restored early in the boot process
  # ============================================================================
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true; # Hide the bind mounts (avoid confusing duplicates in /persistent)

    # Directories to persist (recursively)
    # These will be bind-mounted from /persistent/{dir} to {dir}
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi networks and passwords
      "/etc/rclone" # Rclone cloud storage credentials (MEGA, etc.)
      "/var/log" # Systemd journal logs (automatic rotation via journald.nix)
      "/var/lib/bluetooth" # Bluetooth device pairings
      "/var/lib/systemd" # Systemd service state (timers, etc.)
      "/var/lib/nixos" # User/group IDs (prevent UID/GID reassignment on reinstall)
      "/var/lib/tailscale" # Tailscale state (machine identity, keys, config)
      # Note: /nix is a separate BTRFS subvolume (@nix) → no need to persist
    ];

    # Individual files to persist (symlinks from /persistent to target)
    # Use for files that don't belong in a directory
    files = [
      "/etc/machine-id" # Unique system identifier (required for systemd)
      "/etc/ssh/ssh_host_rsa_key" # SSH host key (prevents "unknown host" warnings)
      "/etc/ssh/ssh_host_ed25519_key" # SSH host key (Ed25519 variant)
      "/etc/ssh/agenix_ssh_key" # Agenix secret decryption key
      # Note: /var/lib/systemd/random-seed removed → conflicts with systemd-random-seed.service
    ];

    # ============================================================================
    # USER-LEVEL PERSISTENCE
    # ============================================================================
    # Paths relative to the user's home directory (~)
    # Impermanence automatically prepends ${config.users.users.${username}.home}
    # ============================================================================
    users.${username} = {
      directories = [
        ".cache" # Application cache (Firefox stores state here)
        ".claude" # Claude Code state (chat history, command whitelist, etc.)
        ".config/op" # 1Password CLI config, accounts, and session tokens
        ".local/share/nix" # Nix user profile data
        ".local/state/home-manager" # Home-manager state (generations, etc.)
        ".local/state/nix" # Nix user state (profiles, etc.)
        ".mozilla/firefox/default" # Firefox profile (cookies, history, bookmarks, etc.)
        ".ssh" # SSH keys and config

        "my-nixos-config" # This NixOS configuration repository
        "src" # Source code repositories
      ];

      files = [
        ".zsh_history" # Zsh command history
      ];
    };
  };

  # ============================================================================
  # ROOT SUBVOLUME WIPE MECHANISM (Impermanence)
  # ============================================================================
  # This script runs AFTER LUKS decryption but BEFORE mounting the root filesystem
  # It ensures the root filesystem (@) starts fresh on every boot
  #
  # Execution order during boot:
  # 1. LUKS decryption (initrdUnlock=true in disko.nix)
  # 2. Run this script (postResumeCommands)
  # 3. Mount root subvolume (/)
  # 4. Switch root and continue boot
  #
  # Benefits:
  # - System state is always predictable (no accumulation of cruft)
  # - Forces all important state to be explicitly persisted via impermanence
  # - Prevents "it works on my machine" issues from accumulated state
  # ============================================================================
  boot.initrd.postResumeCommands = lib.mkAfter ''
    # Mount the BTRFS root device to access all subvolumes
    # We're operating in the initrd environment before the real root is mounted
    mkdir /btrfs_tmp
    mount /dev/mapper/luks-root /btrfs_tmp

    # Archive the previous root subvolume (if it exists)
    # This gives us a chance to recover data if something goes wrong
    # The archived root will be deleted immediately below (no retention)
    if [[ -e /btrfs_tmp/@ ]]; then
      mkdir -p /btrfs_tmp/old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
      mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Recursively delete ALL old root subvolumes
    # BTRFS requires deleting nested subvolumes before deleting the parent
    # This function performs a depth-first deletion of the subvolume tree
    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    # Delete every archived root subvolume (no retention policy)
    # Change this if you want to keep old roots for rollback capability
    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1); do
      delete_subvolume_recursively "$i"
    done

    # Create a fresh, empty root subvolume for the new boot
    # This subvolume will be mounted as / and contains the running system
    btrfs subvolume create /btrfs_tmp/@

    # Cleanup: unmount the BTRFS root device
    # The system will now mount @ as the real root filesystem
    umount /btrfs_tmp
  '';

  # Enable FUSE for home-manager bind mounts
  programs.fuse.userAllowOther = true;
}
