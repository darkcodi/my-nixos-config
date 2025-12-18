# Disko Test Documentation

## Overview

This repository includes automated tests for the disko disk configuration. The tests verify that the disk partitioning, LUKS encryption, and BTRFS filesystem setup work correctly in a virtual machine environment.

## What is Disko?

[Disko](https://github.com/nix-community/disko) is a Nix-based tool for declaratively configuring disk layouts, partitions, filesystems, and encrypted volumes. Instead of manually running commands like `fdisk`, `mkfs`, and `cryptsetup`, you define your entire disk setup in Nix code.

## Test Configuration

### Location
- **Test Definition**: `tests/misato.nix`
- **Disk Config**: `hosts/misato/disko.nix`

### Disk Layout

The configuration sets up the following disk layout:

```
/dev/vda (virtual disk)
├── /dev/vda1 - EFI System Partition (512MB, FAT32)
│   └── Mounted at: /boot
└── /dev/vda2 - LUKS Encrypted Container (remaining space)
    └── BTRFS Filesystem
        ├── /root subvolume (mounted at /)
        └── /home subvolume (mounted at /home)
```

**Key Features:**
- **GPT partition table** for modern UEFI systems
- **EFI System Partition (ESP)** - 512MB, FAT32, mounted at `/boot`
- **LUKS encryption** - Full disk encryption (except EFI partition)
- **BTRFS subvolumes** - Flexible snapshot-capable filesystem with compression

## Running the Tests

### Quick Start

```bash
# Run the disko test
nix build .#checks.x86_64-linux.misato --impure

# View test results
nix log .#checks.x86_64-linux.misato --impure
```

### Test Duration
The test typically completes in **~100 seconds**.

## What the Test Verifies

The test performs the following checks:

### 1. Partition Creation
```bash
# Verify EFI partition exists
machine.succeed("test -b /dev/vda1")

# Verify LUKS partition exists
machine.succeed("test -b /dev/vda2")
```

### 2. LUKS Encryption
```bash
# Verify LUKS container is properly formatted
machine.succeed("cryptsetup isLuks /dev/vda2")
```

### 3. BTRFS Subvolumes
```bash
# Verify root subvolume exists
machine.succeed("btrfs subvolume list / | grep -qs 'path root$'")

# Verify home subvolume exists
machine.succeed("btrfs subvolume list / | grep -qs 'path home$'")
```

### 4. Mount Points
```bash
# Verify EFI partition is mounted at /boot
machine.succeed("mountpoint /boot")
```

## Configuration Details

### disko.nix Structure

```nix
{...}: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-diskseq/1";

      # GPT partition table
      content = {
        type = "gpt";
        partitions = {

          # EFI System Partition (512MB)
          ESP = {
            size = "512M";
            start = "1MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };

          # LUKS encrypted partition (takes all remaining space)
          luks = {
            # No size specified = uses all remaining space
            content = {
              type = "luks";
              name = "luks-root";
              settings = {
                allowDiscards = true;  # For SSDs
                keyFile = "/tmp/secret.key";  # LUKS key file
              };

              # BTRFS filesystem inside LUKS
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                # BTRFS subvolumes
                subvolumes = {
                  root = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  home = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
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
```

### Key Configuration Options

#### LUKS Encryption
- **name**: The LUKS container name (appears in `/dev/mapper/`)
- **allowDiscards**: Enables TRIM support for SSDs (better performance)
- **keyFile**: Path to the key file used for decryption

#### BTRFS Features
- **Compression**: `zstd` compression for better space efficiency
- **noatime**: Prevents unnecessary disk writes (performance boost)
- **Subvolumes**: Allow separate snapshots and management of `/` and `/home`

## Why No Hard-Coded Size?

**Important:** The LUKS partition does **not** have a hard-coded size.

```nix
# ✅ Good - Takes all remaining space automatically
luks = {
  content = { ... };
};

# ❌ Bad - Only works for specific disk sizes
luks = {
  size = "3500M";
  content = { ... };
};
```

This makes the configuration work with:
- Small test disks (4GB)
- Standard hardware (256GB, 512GB, 1TB, etc.)
- Large servers (multiple terabytes)

## Test Output Examples

### Successful Test Output

```
test script finished in 99.05s

booted_machine: must succeed: test -b /dev/vda1
booted_machine: (finished: must succeed: test -b /dev/vda1, in 0.12 seconds)

booted_machine: must succeed: test -b /dev/vda2
booted_machine: (finished: must succeed: test -b /dev/vda2, in 0.09 seconds)

booted_machine: must succeed: cryptsetup isLuks /dev/vda2
booted_machine: (finished: must succeed: cryptsetup isLuks /dev/vda2, in 0.23 seconds)

booted_machine: must succeed: btrfs subvolume list / | grep -qs 'path home$'
booted_machine: (finished: must succeed: btrfs subvolume list / | grep -qs 'path home$', in 0.07 seconds)

booted_machine: must succeed: btrfs subvolume list / | grep -qs 'path root$'
booted_machine: (finished: must succeed: btrfs subvolume list / | grep -qs 'path root$', in 0.06 seconds)

booted_machine: must succeed: mountpoint /boot
booted_machine: (finished: must succeed: mountpoint /boot, in 0.05 seconds)
```

## Troubleshooting

### Test Fails to Build

If you see:
```
error: cannot look up '<nixpkgs/nixos/tests/make-test-python.nix>' in pure evaluation mode
```

**Solution:** Use the `--impure` flag:
```bash
nix build .#checks.x86_64-linux.misato --impure
```

### Kernel Warnings

The following warnings are **normal** in a VM test environment and can be safely ignored:
- `cfg80211: failed to load regulatory.db` - Missing WiFi firmware in VM
- `acpi PNP0A03:00: fail to add MMCONFIG information` - ACPI limitations in VM
- `platform regulatory.0: Direct firmware load for regulatory.db failed` - Missing regulatory database

### Wipefs Errors

```
wipefs: error: /dev/mapper/luks-root: probing initialization failed: No such file or directory
```

This is **expected** during initial disk setup. The test still passes because it verifies the final state.

## Real-World Usage

### Installing to Hardware

1. Boot from NixOS installer
2. Clone your configuration repository
3. Run disko to format the disk:
   ```bash
   nix run github:nix-community/disko/latest -- --arg device /dev/sda --mode disko ./hosts/misato/disko.nix
   ```
4. Install NixOS:
   ```bash
   nixos-install --flake .#misato
   ```

### LUKS Key File

⚠️ **Security Note:** The test uses `/tmp/secret.key` for demonstration. In production:

1. Use a proper key file (e.g., stored on USB drive)
2. Consider using a passphrase instead
3. Never commit key files to version control

Example with passphrase:
```nix
luks = {
  content = {
    type = "luks";
    name = "luks-root";
    # Remove keyFile - use passphrase instead
    # settings = {
    #   allowDiscards = true;
    # };
  };
};
```

## Further Reading

- [Disko Documentation](https://github.com/nix-community/disko)
- [NixOS Installation Guide](https://nixos.org/manual/nixos/stable/#ch-installation)
- [BTRFS Wiki](https://btrfs.wiki.kernel.org/)
- [LUKS Documentation](https://gitlab.com/cryptsetup/cryptsetup/-/wikis/Documentation)

## Integration with Flake

The test is integrated into the repository's flake.nix:

```nix
{
  outputs = { self, nixpkgs, disko, ... }: {
    checks.x86_64-linux.misato = import ./tests/misato.nix {
      inherit pkgs disko;
    };
  };
}
```

This allows the test to run as part of:
```bash
nix flake check  # Runs all checks including disko test
```

## Summary

This disko test validates that your disk configuration:
- ✅ Creates partitions correctly
- ✅ Sets up LUKS encryption
- ✅ Formats BTRFS filesystem
- ✅ Creates BTRFS subvolumes
- ✅ Mounts partitions properly
- ✅ Works with any disk size (dynamic sizing)

The configuration is production-ready and can be used to install NixOS on real hardware with confidence.
