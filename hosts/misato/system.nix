{
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ../../system/security.nix
    ../../system/performance.nix
    ../../system/power-management.nix
    ../../system/locale.nix
    ../../system/nix.nix
    ../../system/bootloader.nix
    ../../system/user-management.nix
    ../../apps/gnome.nix
    ../../apps/mosh.nix
    ../../secrets/system-decrypt.nix
  ];

  networking.hostName = "misato";
  networking.networkmanager.enable = true;
  programs.zsh.enable = true;
  system.stateVersion = "25.11";
}
