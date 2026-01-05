# Declarative disk partitioning and formatting using Disko
# Defines the complete disk layout: GPT partitions, LUKS encryption, and BTRFS subvolumes
{...}: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Device path identifies the disk by PCI location (persistent across reboots)
        device = "/dev/disk/by-path/pci-0000:00:17.0-ata-2";

        content = {
          type = "gpt"; # GPT partition table (modern standard)

          partitions = {
            # EFI System Partition - required for UEFI boot
            ESP = {
              size = "512M"; # Sufficient for storing kernels and initrds
              type = "EF00"; # GPT type code for EFI System Partition

              content = {
                type = "filesystem";
                format = "vfat"; # FAT32 is required for EFI
                mountpoint = "/boot";
                mountOptions = ["umask=0077"]; # Restrict permissions for security
              };
            };

            # LUKS-encrypted partition containing the root filesystem
            luks = {
              size = "100%"; # Use remaining disk space

              content = {
                type = "luks"; # LUKS2 encryption (full-disk encryption)
                name = "luks-root"; # Mapper name: /dev/mapper/luks-root
                initrdUnlock = true; # Prompt for passphrase in initrd (before boot)

                settings = {
                  # Enable TRIM support for SSD performance
                  # WARNING: Only safe if the threat model doesn't include SSD wear pattern analysis
                  allowDiscards = true;
                };

                content = {
                  type = "btrfs"; # BTRFS filesystem with subvolumes
                  extraArgs = ["-f"]; # Force creation (overwrite existing)

                  # BTRFS subvolumes for different mount points
                  # This allows independent snapshots and management
                  subvolumes = {
                    # Root filesystem - wiped on every boot (ephemeral)
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=@"];
                    };

                    # Persistent storage - survives reboots
                    # Managed by impermanence for selective file/directory persistence
                    "@persistent" = {
                      mountpoint = "/persistent";
                      mountOptions = ["subvol=@persistent"];
                    };

                    # Nix store - survives reboots
                    # Separate subvolume allows independent snapshot management
                    # Also benefits from BTRFS compression (copy-on-write)
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=@nix"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
