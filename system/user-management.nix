{
  pkgs,
  username,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    hashedPasswordFile = "/run/agenix/darkcodiPassword";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5KY8Y1PPz4f/QaiHzKeZZB6nE9cxXXiTkebVvLvmie u0_a396@localhost"
    ];
  };
}
