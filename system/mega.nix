# ============================================================================
# MEGA CLOUD STORAGE CONFIGURATION
# ============================================================================
{
  pkgs,
  username,
  ...
}: {
  # Install MEGAcmd CLI and davfs2 WebDAV filesystem driver
  environment.systemPackages = with pkgs; [
    megacmd # MEGAcmd CLI suite (mega-cmd-server, mega-*, etc.)
    davfs2 # WebDAV filesystem driver
  ];

  # ========================================================================
  # USER-LEVEL SYSTEMD SERVICES
  # ========================================================================
  # MEGA runs as user service for better security and proper home directory access

  systemd.user.services.mega-cmd-server = {
    description = "MEGAcmd WebDAV Server";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["default.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
      ExecStartPost = pkgs.writeShellScript "mega-start-webdav" ''
        # Wait for mega-cmd-server to be ready
        sleep 5

        # Start WebDAV server on port 8080
        # This will use persisted credentials from ~/.megaCmd
        ${pkgs.megacmd}/bin/mega-exec webdav / --port=8080 || true
      '';
      Restart = "always";
      RestartSec = "10s";
    };
  };

  systemd.user.services.mega-webdav-mount = {
    description = "Mount MEGA WebDAV at /mega";
    after = ["mega-cmd-server.service"];
    requires = ["mega-cmd-server.service"];
    wantedBy = ["default.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";

      ExecStart = pkgs.writeShellScript "mount-mega" ''
        #!/bin/sh
        set -e

        # Wait for MEGAcmd WebDAV server to be ready
        echo "Waiting for MEGAcmd WebDAV server..."
        for i in $(seq 1 60); do
          if ${pkgs.curl}/bin/curl -s http://localhost:8080 > /dev/null 2>&1; then
            echo "MEGAcmd WebDAV server is ready!"
            break
          fi
          if [ "$i" -eq 60 ]; then
            echo "Timeout waiting for MEGAcmd WebDAV server"
            echo "Make sure you've run 'mega-login' at least once!"
            exit 1
          fi
          sleep 1
        done

        # Create mount point if it doesn't exist
        mkdir -p /mega

        # Mount WebDAV endpoint
        echo "Mounting MEGA at /mega..."
        ${pkgs.davfs2}/bin/mount.davfs http://localhost:8080 /mega \
          -o "uid=$(id -u),gid=$(id -g),user,noauto"
        echo "MEGA mounted successfully at /mega"
      '';

      ExecStop = pkgs.writeShellScript "unmount-mega" ''
        #!/bin/sh
        ${pkgs.davfs2}/bin/umount.davfs /mega || true
      '';

      Restart = "on-failure";
      RestartSec = "5s";
      User = username;
    };
  };
}
