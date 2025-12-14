{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";

      # config without an auth token
      env = {
        ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic";
        # ANTHROPIC_AUTH_TOKEN = "<MINIMAX_CODING_PLAN_API_KEY>";
        API_TIMEOUT_MS = "3000000";
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
        ANTHROPIC_MODEL = "MiniMax-M2";
        ANTHROPIC_SMALL_FAST_MODEL = "MiniMax-M2";
        ANTHROPIC_DEFAULT_SONET_MODEL = "MiniMax-M2";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "MiniMax-M2";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2";
      };
    };
  };

  # wrapper injects an auth token at runtime from the decrypted path
  home.packages = [
    (pkgs.writeShellScriptBin "claude-m2" ''
      export ANTHROPIC_AUTH_TOKEN="$(cat ${config.age.secrets.minimaxCodingPlanApikey.path})"
      exec ${pkgs.claude-code}/bin/claude "$@"
    '')
  ];
}
