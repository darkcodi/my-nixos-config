# Secrets Management with Agenix

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## Prerequisites

Make sure you have the `agenix` CLI available. You can use it via nix:
```bash
nix run github:ryantm/agenix -- <command>
```

Or add it to your packages for convenience.

## File Structure

- `secrets.nix` - Defines which public keys can decrypt each secret
- `decrypt.nix` - Home-manager configuration for age secrets
- `*.age` - Encrypted secret files

## Adding a New Secret

### 1. Register the secret in `secrets.nix`

Add an entry specifying which public keys can decrypt it:

```nix
  "new-secret.age".publicKeys = [ nixos-misato-pubkey ];  # <-- add this
```

### 2. Create the encrypted file

```bash
cd /home/darkcodi/nixos/secrets
nix run github:ryantm/agenix -- -e new-secret.age
```

This opens your `$EDITOR`. Type/paste the secret content, save, and exit.

### 3. Configure decryption in `decrypt.nix`

Add the secret to `age.secrets` in `secrets/decrypt.nix`:

```nix
age.secrets = {
  "new-secret" = {
    file = ./new-secret.age;
    path = "${homeDir}/.config/app/secret.txt";  # where to decrypt
    mode = "0400";  # file permissions (readonly)
  };
};
```

### 4. Rebuild

```bash
sudo nixos-rebuild switch --flake .#misato
```

The secret will be decrypted to the specified `path` on activation.

## Importing an Existing File as a Secret

If an application already created a config file (e.g., `~/.config/app/credentials.conf`) and you want to encrypt it:

### 1. Register in `secrets.nix`

```nix
"app-credentials.age".publicKeys = [ nixos-misato-pubkey ];
```

### 2. Encrypt the existing file

```bash
cd /home/darkcodi/nixos/secrets
nix run github:ryantm/agenix -- -e app-credentials.age < ~/.config/app/credentials.conf
```

Or copy-paste manually:
```bash
cat ~/.config/app/credentials.conf  # copy content
nix run github:ryantm/agenix -- -e app-credentials.age  # paste in editor
```

### 3. Configure in `decrypt.nix`

```nix
age.secrets."app-credentials" = {
  file = ./app-credentials.age;
  path = "${homeDir}/.config/app/credentials.conf";
  mode = "0600";
};
```

### 4. Remove the original unencrypted file

After confirming the encrypted version works:
```bash
rm ~/.config/app/credentials.conf
sudo nixos-rebuild switch --flake .#misato
```

## Updating/Refreshing a Secret

If a program modified a decrypted file (e.g., appended data to `~/.config/app/config.conf`) and you need to update the `.age` file:

### Option 1: Re-encrypt from the current file

```bash
cd /home/darkcodi/nixos/secrets
nix run github:ryantm/agenix -- -e app-config.age < ~/.config/app/config.conf
```

This overwrites `app-config.age` with the new encrypted content.

### Option 2: Edit interactively

```bash
cd /home/darkcodi/nixos/secrets
nix run github:ryantm/agenix -- -e app-config.age
```

This decrypts to your editor, where you can modify and save.

### After updating

Commit the changes and rebuild:
```bash
git add app-config.age
git commit -m "Update app-config secret"
sudo nixos-rebuild switch --flake .#misato
```

## Rekeying Secrets

If you add/remove a public key in `secrets.nix`, rekey all affected secrets:

```bash
cd /home/darkcodi/nixos/secrets
nix run github:ryantm/agenix -- -r
```

This re-encrypts all secrets with the updated key list.

## Common Options

| Option | Description |
|--------|-------------|
| `file` | Path to the `.age` file |
| `path` | Where to decrypt the secret (defaults to `/run/agenix/secret-name`) |
| `mode` | File permissions (e.g., `"0400"` readonly, `"0600"` read/write) |
| `owner` | File owner (defaults to `root` for system, user for home-manager) |
| `group` | File group |
| `symlink` | Whether to symlink instead of copy (default: true) |

## Tips

- Use `mode = "0400"` for readonly secrets (API keys, tokens)
- Use `mode = "0600"` if the application needs to modify the file
- Secrets are decrypted on each system activation
- Keep `.age` files in git; they're encrypted and safe to commit
- Never commit unencrypted secrets!
