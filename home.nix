{ config, pkgs, ... }:

let
  username = "darkcodi";
  homeDir = "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep fd bat eza
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = username;
      user.email = "trooper982@gmail.com";
      init.defaultBranch = "master";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3; # restore previous session
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alh";
      rebuild-switch="sudo nixos-rebuild switch --flake .#misato";
    };

    initContent = ''
      # extra zsh config here
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        # "docker"
      ];
      extraConfig = ''
        DISABLE_AUTO_UPDATE="true"
      '';
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.claude-code = {
    enable = true;
    #settings = {
    #  env = {
    #    ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic";
    #    ANTHROPIC_AUTH_TOKEN = "<MINIMAX_CODING_PLAN_API_KEY>";
    #    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
    #    ANTHROPIC_MODEL = "MiniMax-M2";
    #    ANTHROPIC_SMALL_FAST_MODEL = "MiniMax-M2";
    #    ANTHROPIC_DEFAULT_SONET_MODEL = "MiniMax-M2";
    #    ANTHROPIC_DEFAULT_OPUS_MODEL = "MiniMax-M2";
    #    ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2";
    #  };
    #};
  };

  # Agenix configuration for user secrets
  age.identityPaths = [ "${homeDir}/.ssh/id_ed25519" ];
  age.secrets = {
    # Example secret: API key for sometool
    "sometool-apikey" = {
      file = ./secrets/sometool-apikey.age;
      path = "${homeDir}/.sometool/apikey.txt";
      mode = "0400"; # readonly
    };
  };
}
