{
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ../../apps/gnome.nix
    ../../secrets/system-decrypt.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    hashedPasswordFile = "/run/agenix/darkcodiPassword";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ============================
  # Performance Optimizations
  # ============================

  # Binary caches - DRAMATICALLY speeds up rebuilds
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6ebFG5uMUzwInV3pXShvmwDagY4tRczN9PhqG5mxhjs="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimSvo6ov48y4zqeio6QZoMUa1C7PE/U="
  ];

  # Build with more cores (auto-detect)
  nix.settings.max-jobs = lib.mkDefault "auto";

  # Build remote builds (use other machines if available)
  nix.settings.builders-use-substitutes = true;

  # Keep build outputs for faster rebuilds
  nix.settings.keep-going = true;
  nix.settings.keep-outputs = true;

  # Regular garbage collection + prune old generations
  nix.gc = {
    automatic = true;

    # systemd.time(7) format; "weekly" is common
    dates = "weekly";

    # nice on laptops / fleets so everything doesn't hammer disk at once
    randomizedDelaySec = "15min";

    # this is the big one: deletes profiles generations older than N days
    options = "--delete-older-than 14d";
  };

  # Deduplicate the store (saves space; can take time on big stores)
  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "misato"; # Define your hostname.

  # Install zsh
  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
