{
  config,
  pkgs,
  ...
}: let
  claudeOriginal = pkgs.claude-code;
  claudeWrapped = pkgs.writeShellScriptBin "claude" ''
    # Check if secret is available before using it
    secret_path="${config.age.secrets.zaiCodingPlanApikey.path}"

    if [ ! -f "$secret_path" ]; then
      echo "❌ Error: Claude Code API secret not available" >&2
      echo "   Expected at: $secret_path" >&2
      echo "" >&2
      echo "Troubleshooting:" >&2
      echo "  1. Check agenix: systemctl --user status agenix.service" >&2
      echo "  2. Check secret: ls -la ~/.zai/apikey.txt" >&2
      echo "  3. Rebuild: sudo nixos-rebuild switch --flake .#misato" >&2
      exit 1
    fi

    export ANTHROPIC_AUTH_TOKEN="$(cat "$secret_path")"
    exec ${claudeOriginal}/bin/claude "$@"
  '';
in {
  programs.claude-code = {
    enable = true;
    package = claudeWrapped;
    settings = {
      theme = "dark";

      # config without an auth token
      env = {
        #ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic";
        ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
        API_TIMEOUT_MS = "3000000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
        #ANTHROPIC_MODEL = "MiniMax-M2.1";
        #ANTHROPIC_SMALL_FAST_MODEL = "MiniMax-M2.1";
        #ANTHROPIC_DEFAULT_SONET_MODEL = "MiniMax-M2.1";
        #ANTHROPIC_DEFAULT_OPUS_MODEL = "MiniMax-M2.1";
        #ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2.1";
        MAX_THINKING_TOKENS = "31999";
      };
    };
  };
}
