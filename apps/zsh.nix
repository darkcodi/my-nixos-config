{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alh";
      rebuild-switch = "sudo nixos-rebuild switch --flake .#misato";
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
}
