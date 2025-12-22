{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # extra zsh config here
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        # "git"
        "sudo"
        # "docker"
      ];
      extraConfig = ''
        DISABLE_AUTO_UPDATE="true"
      '';
    };
  };
}
