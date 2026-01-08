## Secrets Architecture

This repository uses **Agenix** to encrypt secrets with age, stored in `age-files/` directory.

- **System secrets**: Decrypted to `/run/agenix/` via `system-decrypt.nix`
- **User secrets**: Decrypted to home directory via `user-decrypt.nix` (home-manager)
- **Identity keys**:
  - System: `/persistent/etc/ssh/agenix_ssh_key`
  - User: `/etc/ssh/agenix_ssh_key`

### Current Secrets

**System-level** (`system-decrypt.nix`):
- `darkcodi-password.age` → `/run/agenix/darkcodiPassword`
- `tailscale-auth-key.age` → `/run/agenix/tailscale-auth-key`

**User-level** (`user-decrypt.nix`):
- `minimax-coding-plan-apikey.age` → `~/.minimax/apikey.txt`
- `nixos-misato-ssh-privkey.age` → `~/.ssh/id_ed25519`
- `nixos-misato-ssh-pubkey.age` → `~/.ssh/id_ed25519.pub`
- `zai-coding-plan-apikey.age` → `~/.zai/apikey.txt`
- `crates-io-api-token.age` → `~/.crates-io/apitoken.txt`

**Infrastructure**:
- `agenix_ssh_key.age` → Agenix identity key (used to decrypt other secrets)

## Adding a New Secret

### 1. Change directory to ./secrets

Don't forget to change dir first, because agenix looks for secrets.nix file in a current dir.

```bash
cd $HOME/my-nixos-config/secrets
```

### 2. Register the secret in `secrets.nix`

Add an entry specifying which public keys can decrypt it:

```nix
  "age-files/new-secret.age".publicKeys = [agenix-pubkey];  # <-- add this
```

### 3. Create the encrypted file

Run this if you want to paste secret in $EDITOR:

```bash
nix run github:ryantm/agenix -- -e age-files/new-secret.age
```

Or run this if you want to encrypt an existing file

```bash
nix run github:ryantm/agenix -- -e age-files/new-secret.age < ~/.config/app/credentials.conf
```

### 4. Configure decryption

**For system-level secrets** (decrypted to `/run/agenix/`):

Add to `secrets/system-decrypt.nix`:

```nix
age.secrets = {
  "newSecret" = {
    file = ./age-files/new-secret.age;
    path = "/run/agenix/newSecret";
    mode = "0400";
    owner = "root";
    group = "root";
  };
};
```

**For user-level secrets** (decrypted to home directory):

Add to `secrets/user-decrypt.nix`:

```nix
{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  age.secrets = {
    "newSecret" = {
      file = ./age-files/new-secret.age;
      path = "${homeDir}/.config/app/credentials.conf";  # where to decrypt
      mode = "0400";  # file permissions (readonly)
    };
  };
}
```

### 5. Rebuild

```bash
sudo nixos-rebuild switch --flake .#misato
```

The secret will be decrypted to the specified `path` on activation.

## Rekeying Secrets

If you add/remove a public key in `secrets.nix`, rekey all affected secrets:

```bash
nix run github:ryantm/agenix -- -r
```
