{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ../../common/nixos.nix
    ../../common/impermanence.nix
    ../../apps/gnome.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "misato"; # Define your hostname.

  # Install zsh
  programs.zsh.enable = true;
}
