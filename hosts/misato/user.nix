{...}: {
  imports = [
    ../../apps/base-packages.nix
    ../../apps/git.nix
    ../../apps/firefox.nix
    ../../apps/default-apps.nix
    ../../apps/zsh.nix
    ../../apps/direnv.nix
    ../../apps/claude-code.nix
    ../../apps/rust.nix
    ../../apps/rjd.nix
    ../../apps/aliases.nix
    ../../secrets/user-decrypt.nix
  ];
}
