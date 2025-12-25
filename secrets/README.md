## Adding a new secret

### 1. Change directory to ./secrets

Don't forget to change dir first, because agenix looks for secrets.nix file in a current dir.

```bash
cd $HOME/my-nixos-config/secrets
```

### 2. Register the secret in `secrets.nix`

Add an entry specifying which public keys can decrypt it:

```nix
  "new-secret.age".publicKeys = [ nixos-misato-pubkey ];  # <-- add this
```

### 3. Create the encrypted file

Run this if you want to paste secret in $EDITOR:

```bash
nix run github:ryantm/agenix -- -e new-secret.age
```

Or run this if you want to encrypt an existing file

```bash
nix run github:ryantm/agenix -- -e new-secret.age < ~/.config/app/credentials.conf
```

### 4. Configure decryption in `decrypt.nix`

Add the secret to `age.secrets` in `secrets/decrypt.nix`:

```nix
age.secrets = {
  "new-secret" = {
    file = ./new-secret.age;
    path = "${homeDir}/.config/app/credentials.conf";  # where to decrypt
    mode = "0400";  # file permissions (readonly)
  };
};
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
