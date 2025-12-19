{
  config,
  pkgs,
  lib,
  ...
}: {
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

  home.activation.cloneMyRepo = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "/home/darkcodi/my-nixos-config/.git" ]; then
      ${pkgs.git}/bin/git clone "https://github.com/darkcodi/my-nixos-config" "/home/darkcodi/my-nixos-config"
      ${pkgs.git}/bin/git -C "/home/darkcodi/my-nixos-config" remote set-url origin "git@github.com:darkcodi/my-nixos-config.git"
    fi
  '';
}
