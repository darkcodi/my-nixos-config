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

  # ============================================================================
  # POWER MANAGEMENT - Prevent Sleep & Hibernate
  # ============================================================================
  # System behavior: Never sleep from lid close OR inactivity (AC or battery)
  # - Lid close: Screen turns off, system stays running
  # - Inactivity: No automatic sleep ever
  # - Background processes continue uninterrupted (downloads, servers, etc.)

  services.logind = {
    # Lid close behavior - system NEVER sleeps when closing lid
    lidSwitch = "ignore"; # On battery: ignore lid close (don't sleep)
    lidSwitchExternalPower = "ignore"; # On AC power: ignore lid close (don't sleep)
    lidSwitchDocked = "ignore"; # When docked: ignore lid close (don't sleep)

    # Inactivity behavior - system NEVER sleeps from being idle
    idleAction = "ignore"; # Don't sleep when inactive
    idleActionSec = 0; # Disable idle timer completely (0 = disabled)
  };

  # ============================================================================
  # SCREEN MANAGEMENT - Turn Off Display on Lid Close
  # ============================================================================
  # Custom systemd service that monitors laptop lid state and controls display
  # - When lid closes: Turn off screen (system keeps running)
  # - When lid opens: Turn on screen
  # - Polls /proc/acpi/button/lid/LID0/state every 2 seconds

  systemd.services.lid-screen-handler = {
    description = "Turn off screen when lid is closed";
    after = ["graphical.target" "display-manager.service"];
    wants = ["graphical.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "lid-screen-handler" ''
        # X11 display environment variables for xset commands
        export DISPLAY=:0
        export XAUTHORITY=/run/user/1000/gdm/Xauthority

        # Infinite loop: monitor lid state and control display power
        while true; do
          # Read lid state from ACPI (outputs: "open" or "closed")
          LID_STATE=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null | awk '{print $2}')

          if [ "$LID_STATE" = "closed" ]; then
            # Lid closed: force all displays to turn off immediately
            ${pkgs.xorg.xset}/bin/xset dpms force off 2>/dev/null || true
          else
            # Lid opened: force all displays to turn on immediately
            ${pkgs.xorg.xset}/bin/xset dpms force on 2>/dev/null || true
          fi

          # Wait 2 seconds before checking again (prevents excessive CPU usage)
          sleep 2
        done
      '';
      Restart = "always"; # Restart service if it crashes
      RestartSec = "5s"; # Wait 5 seconds before restarting
      User = "darkcodi"; # Run as user (not root) for X11 access
    };
  };

  # ============================================================================
  # SCREEN BLANKING - Disable Automatic Screen Power Saving
  # ============================================================================
  # Prevent X11 from automatically turning off screen due to inactivity
  # - Screen only turns off when lid is closed (handled by service above)
  # - Screen stays on indefinitely when lid is open

  services.xserver.displayManager.sessionCommands = ''
    xset s off        # Disable X11 screensaver (no timeout)
    xset -dpms        # Disable DPMS (Display Power Management Signaling)
    xset s noblank    # Prevent screen from blanking
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
