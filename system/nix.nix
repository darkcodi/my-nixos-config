{ ... }: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
