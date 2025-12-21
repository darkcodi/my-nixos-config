{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../common/nixos.nix
    ../../apps/gnome.nix
  ];

  # Add QEMU for VM testing
  environment.systemPackages = with pkgs; [
    qemu_full
    libvirt
    virt-manager
  ];

  # Enable libvirtd
  virtualisation.libvirtd.enable = true;
  users.groups.libvirtd = {};

  # File system configuration for persistent storage
  # Required by impermanence: neededForBoot = true
  # Note: disko handles the creation, we just need to mark it as neededForBoot
  fileSystems."/persistent" = {
    device = "/dev/mapper/luks-root";
    fsType = "btrfs";
    options = ["subvol=@persistent"];
    neededForBoot = true;
  };

  # Persistence configuration
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;

    # Critical system paths to persist
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi configs
      "/var/lib/bluetooth" # Bluetooth pairings
      "/var/lib/systemd" # Systemd state
      "/var/lib/nixos" # Preserve user/group IDs to prevent reassignment
      # Note: /nix is a separate BTRFS subvolume, no need to persist
    ];

    # Files to persist
    files = [
      "/etc/machine-id" # Machine ID
      "/etc/ssh/ssh_host_rsa_key" # SSH host key
      "/etc/ssh/ssh_host_ed25519_key" # SSH host key
      # Note: /var/lib/systemd/random-seed removed - conflicts with systemd-random-seed.service
    ];

    # User-specific persistence using impermanence's user support
    users.darkcodi = {
      directories = [
        ".ssh" # SSH keys
        ".mozilla" # Firefox profile & state
        ".local/state/nix" # Nix state
        ".local/state/home-manager" # Home-manager state
        ".local/share/nix" # Nix user data
        "my-nixos-config" # Main config repo
        ".claude" # Claude code state (chat history, commands whitelist, etc)
      ];

      files = [
        ".zsh_history" # Zsh command history
      ];
    };
  };

  # Enable FUSE for home-manager bind mounts
  programs.fuse.userAllowOther = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "misato"; # Define your hostname.

  # Install zsh
  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
