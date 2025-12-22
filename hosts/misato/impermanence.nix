{
  lib,
  config,
  username,
  ...
}: {
  # File system configuration for persistent storage
  # Required by impermanence: neededForBoot = true
  # Note: disko handles the creation, we just need to mark it as neededForBoot
  fileSystems."/persistent" = {
    device = "/dev/mapper/luks-root";
    fsType = "btrfs";
    options = ["subvol=@persistent"];
    neededForBoot = true;
  };

  # Persistence configuration
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;

    # Critical system paths to persist
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi configs
      "/var/lib/bluetooth" # Bluetooth pairings
      "/var/lib/systemd" # Systemd state
      "/var/lib/nixos" # Preserve user/group IDs to prevent reassignment
      # Note: /nix is a separate BTRFS subvolume, no need to persist
    ];

    # Files to persist
    files = [
      "/etc/machine-id" # Machine ID
      "/etc/ssh/ssh_host_rsa_key" # SSH host key
      "/etc/ssh/ssh_host_ed25519_key" # SSH host key
      "/etc/ssh/agenix_ssh_key" # Agenix SSH decryption key
      # Note: /var/lib/systemd/random-seed removed - conflicts with systemd-random-seed.service
    ];

    # User-specific persistence using impermanence's user support
    users.${username} = {
      directories = [
        ".cache" # Firefox stores some state there
        ".claude" # Claude code state (chat history, commands whitelist, etc)
        ".local/share/nix" # Nix user data
        ".local/state/home-manager" # Home-manager state
        ".local/state/nix" # Nix state
        ".mozilla/firefox/default" # Firefox profile data (cookies, history, etc.)
        ".ssh" # SSH keys

        "my-nixos-config" # Main config repo
        "src" # Source codes
      ];

      files = [
        ".zsh_history" # Zsh command history
      ];
    };
  };

  # Make the root subvolume ephemeral - official impermanence approach
  boot.initrd.postResumeCommands = lib.mkAfter ''
    # Mount the BTRFS filesystem to see all subvolumes
    mkdir /btrfs_tmp
    mount /dev/mapper/luks-root /btrfs_tmp

    # Archive the old root subvolume
    if [[ -e /btrfs_tmp/@ ]]; then
      mkdir -p /btrfs_tmp/old_roots
      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%d_%H:%M:%S")
      mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Recursively delete ALL old roots immediately (no retention)
    delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
        delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1); do
      delete_subvolume_recursively "$i"
    done

    # Create a fresh empty root subvolume
    btrfs subvolume create /btrfs_tmp/@

    umount /btrfs_tmp
  '';

  # Enable FUSE for home-manager bind mounts
  programs.fuse.userAllowOther = true;
}
