{config, ...}: {
  home.username = "darkcodi";
  home.homeDirectory = "/home/darkcodi";
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      user.name = config.home.username;
      user.email = "trooper982@gmail.com";
      init.defaultBranch = "main";
    };
  };
}
