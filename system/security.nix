{...}: {
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
      # Allow SSH from private subnets (local LAN)
      iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT

      # Allow SSH from Tailscale IPs (100.64.0.0/10 CGNAT range)
      iptables -A INPUT -p tcp --dport 22 -s 100.64.0.0/10 -j ACCEPT

      # Drop all other SSH attempts
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
}
