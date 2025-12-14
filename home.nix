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

  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
