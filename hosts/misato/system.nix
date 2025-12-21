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
    initialPassword = "changeme";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # [TEMP] Disable password prompt for sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

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
