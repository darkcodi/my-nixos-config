# ============================================================================
# RCLONE MEGASTORAGE MOUNT
# ============================================================================
# Mounts MEGA cloud storage using rclone at /mega
#
# Setup instructions (run once):
#   1. Create persistent config directory:
#      sudo mkdir -p /persistent/etc/rclone
#   2. Configure rclone with MEGA:
#      sudo --preserve-env rclone config --config=/persistent/etc/rclone/rclone.conf
#      - Choose "New remote"
#      - Name it "mega"
#   - Choose "MEGA" as storage type
#      - Follow prompts for MEGA credentials
#   3. After rebuild, the mount will be available at /mega
#
# Note: Using system-level (/etc/rclone) config for systemd service access
#       Impermanence persists /etc/rclone → /persistent/etc/rclone
# ============================================================================
{
  config,
  pkgs,
  ...
}: {
  # Install rclone
  environment.systemPackages = with pkgs; [rclone];

  # Mount point is managed by systemd service below
  # NixOS fileSystems doesn't work well with userspace FUSE mounts like rclone
  # This provides better logging and restart capabilities
  systemd.services.rclone-mega = {
    description = "Rclone MEGA Mount Service";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          mega:/ /mega \
          --config=/etc/rclone/rclone.conf \
          --allow-other \
          --vfs-cache-mode full \
          --cache-info-age 168h \
          --dir-cache-time 168h \
          --poll-interval 1m \
          --no-modtime \
          --uid 1000 \
          --gid 1000 \
          --log-level INFO
      '';

      # Restart on failure
      Restart = "on-failure";
      RestartSec = "10s";

      # FUSE configuration
      # CRITICAL: These must be disabled for FUSE mount to be visible system-wide
      PrivateTmp = false; # Don't isolate /tmp (prevents mount visibility)
      MountNamespace = false; # Don't isolate mount namespace (critical for FUSE)

      # Ensure mount point exists
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /mega";

      # Unmount on stop
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz /mega";

      # Safety: don't kill rclone abruptly (might corrupt cache)
      KillMode = "process";
      KillSignal = "SIGTERM";
      TimeoutStopSec = "30";
    };
  };

  # Ensure FUSE is enabled for system mounts
  services.dbus.packages = [pkgs.rclone];
}
