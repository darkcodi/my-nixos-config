{
  config,
  lib,
  ...
}: {
  home.activation.cargoCredentials = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Hardened cargo credentials activation
    # Pattern from lib/hardened-activation.nix (withSecretAndRuntime)
    (
      set -euo pipefail

      # Check if secret is deployed
      if [ ! -f "${config.age.secrets.cratesIoApiToken.path}" ]; then
        echo "⚠️  Secret not deployed: cratesIoApiToken" >&2
        echo "    Expected at: ${config.age.secrets.cratesIoApiToken.path}" >&2
        echo "    This indicates a systemd ordering issue - agenix.service should run first" >&2
        echo "    Check: systemctl --user status agenix.service" >&2
        echo "    Skipping activation..." >&2
        exit 0
      fi

      # Ensure XDG_RUNTIME_DIR is set
      export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

      # Create directory
      mkdir -p ~/.cargo

      # Read and write credentials
      TOKEN=$(cat ${config.age.secrets.cratesIoApiToken.path})
      cat > ~/.cargo/credentials.toml << EOF
    [registry]
    token = "$TOKEN"
    EOF
      chmod 600 ~/.cargo/credentials.toml

    ) || {
      echo "⚠️  Warning: Failed to setup cargo credentials" >&2
      echo "    Continuing with other activations..." >&2
      exit 0
    }
  '';
}
