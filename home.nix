{ config, pkgs, ... }:

{
  home.username = "darkcodi";
  home.homeDirectory = "/home/darkcodi";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep fd bat eza
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "darkcodi";
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
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
