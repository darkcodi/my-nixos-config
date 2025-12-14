{ config, pkgs, lib, ... }:

# Import all app configurations
# To disable an app, comment out its import below

{
  imports = [
    # Core packages
    ./apps/base-packages.nix

    # Applications
    ./apps/git.nix
    ./apps/firefox.nix
    ./apps/zsh.nix
    ./apps/direnv.nix
    ./apps/claude-code.nix

    # Secrets
    ./secrets/decrypt.nix
  ];
}
