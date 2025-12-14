{config, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = config.home.username;
      user.email = "trooper982@gmail.com";
      init.defaultBranch = "master";
    };
  };
}
