# ============================================================================
# TAILSCALE VPN CONFIGURATION
# ============================================================================
{
  config,
  pkgs,
  ...
}: {
  # Enable Tailscale service with all features
  services.tailscale = {
    enable = true;

    # Permit Tailscale to override firewall configuration
    # Safe: Tailscale only adds rules for its own interfaces (tailscale0)
    openFirewall = true;

    # Authentication key for unattended registration
    # Decrypted from Agenix at /run/agenix/tailscale-auth-key
    authKeyFile = config.age.secrets.tailscale-auth-key.path;

    # Enable Tailscale features
    extraUpFlags = [
      "--ssh=false" # Explicitly disable Tailscale SSH
      "--accept-routes" # Accept subnet routes from other nodes
      "--operator=darkcodi" # Set operator user for tailscale status
    ];
  };

  # Make Tailscale CLI available for manual management
  environment.systemPackages = with pkgs; [tailscale];
}
