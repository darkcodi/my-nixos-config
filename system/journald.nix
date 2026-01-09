# ============================================================================
# JOURNALD CONFIGURATION
# ============================================================================
# Systemd journal with automatic log rotation and cleanup
#
# This configures the systemd journal to:
# - Persist logs across reboots (stored in /var/log/journal)
# - Automatically rotate and delete old logs
# - Limit disk usage to prevent filling up the persistent partition
# ============================================================================
{
  services.journald = {
    # Use persistent storage (logs survive reboots)
    # Requires /var/log to be persisted via impermanence
    storage = "persistent";

    # Automatic cleanup configuration
    # Journald will enforce these limits and delete old logs automatically
    extraConfig = ''
      # Maximum total disk space for all journals
      # When this limit is reached, oldest logs are deleted first
      SystemMaxUse=500M

      # Maximum disk space per user journal
      # Prevents one user from monopolizing log space
      PerUserMaxUse=100M

      # Maximum number of journal files per user
      PerUserMaxFiles=100

      # Maximum age of log files
      # Logs older than 2 weeks are automatically deleted
      MaxRetentionSec=14day

      # Maximum age for individual journal files
      # More aggressive rotation for individual files (1 week)
      MaxFileSec=7day
    '';
  };
}
