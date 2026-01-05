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
    ../../apps/mosh.nix
    ../../secrets/system-decrypt.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable SSH server with security hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      X11Forwarding = false;
      UseDns = false;
      MaxAuthTries = 3;
      LoginGraceTime = 60;
    };
    extraConfig = ''
      Protocol 2
      MaxStartups 10:30:100
      PermitEmptyPasswords no
      IgnoreRhosts yes
      StrictModes yes
    '';
  };

  # Configure firewall with local network restrictions
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [22];
    extraCommands = ''
      iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -j DROP
    '';
  };

  # Enable fail2ban for SSH brute-force protection
  services.fail2ban = {
    enable = true;
    jails.sshd.settings = {
      port = "ssh";
      filter = "sshd";
      logpath = "/var/log/auth.log";
      maxretry = 5;
      bantime = "1h";
      findtime = "1h";
    };
  };

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5KY8Y1PPz4f/QaiHzKeZZB6nE9cxXXiTkebVvLvmie u0_a396@localhost"
    ];
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

  # Power Management - Prevent automatic sleep on lid close
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  # Custom service to turn off screen when lid is closed
  systemd.services.lid-screen-handler = {
    description = "Turn off screen when lid is closed";
    after = ["graphical.target" "display-manager.service"];
    wants = ["graphical.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "lid-screen-handler" ''
        # Set display environment
        export DISPLAY=:0
        export XAUTHORITY=/run/user/1000/gdm/Xauthority

        # Monitor lid state
        while true; do
          LID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')

          if [ "$LID_STATE" = "closed" ]; then
            # Turn off all displays
            ${pkgs.xorg.xset}/bin/xset dpms force off 2>/dev/null || true
          else
            # Turn on displays when lid opens
            ${pkgs.xorg.xset}/bin/xset dpms force on 2>/dev/null || true
          fi

          sleep 2
        done
      '';
      Restart = "always";
      RestartSec = "5s";
      User = "darkcodi";
    };
  };

  # Disable screen blanking
  services.xserver.displayManager.sessionCommands = ''
    xset s off
    xset -dpms
    xset s noblank
  '';

  networking.hostName = "misato"; # Define your hostname.

  # Install zsh
  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.11";
}
