# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Important Constraints

- Claude Code cannot run `sudo` - user must manually run: `sudo nixos-rebuild switch --flake .#misato`
- **ALWAYS** validate config after ANY changes with:
  ```bash
  nix --extra-experimental-features 'nix-command flakes' build --print-out-paths '.#nixosConfigurations."misato".config.system.build.nixos-rebuild' --no-link
  ```
- This build check is mandatory and does not require sudo

## Repository Structure

This is a flakes-based NixOS configuration using:
- **Flakes** - Declarative system configuration via `flake.nix`
- **Home-manager** - User-level configuration management
- **Agenix** - Secret encryption/decryption via SSH keys
- **Disko** - Declarative disk partitioning and formatting
- **Impermanence** - Ephemeral root filesystem with selective persistence

```
hosts/misato/
├── disko.nix          # Disk partitioning (BTRFS subvolumes)
├── hardware.nix       # Hardware-specific configuration
├── impermanence.nix   # Persistent directories/files configuration
├── system.nix         # System-level configuration
└── user.nix           # User home-manager imports

apps/                  # Reusable application configurations
secrets/               # Agenix encrypted secrets
```

## Architecture

### Host Configuration Pattern
- `flake.nix` auto-generates configs from the `hosts` attribute set
- Each host has `system.nix` (system-level) and `user.nix` (home-manager)
- System config imports from `apps/` for reusable components
- User config imports from `apps/` for user-specific packages

### Impermanence
- Root filesystem (`@`) is wiped on every boot (ephemeral)
- Persistent storage in `/persistent` via BTRFS subvolume `@persistent`
- Persistent paths defined in `impermanence.nix` under `environment.persistence`
- User-specific persistence uses the `users.${username}` attribute

### Power Management
- System never sleeps; lid close turns off screen but keeps system running
- Background processes continue uninterrupted (downloads, servers, etc.)

### Build Configuration
- Binary caches enabled (cache.nixos.org, nix-community.cachix.org) for faster builds
- Automatic garbage collection runs weekly (deletes generations older than 14d)
- Rust toolchain available via rust-overlay
