{ config, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  # Agenix configuration for user secrets
  age.identityPaths = [ "${homeDir}/.ssh/id_ed25519" ];
  age.secrets = {
    "minimax-coding-plan-apikey" = {
      file = ./minimax-coding-plan-apikey.age;
      path = "${homeDir}/.minimax/apikey.txt";
      mode = "0400"; # readonly
    };
  };
}
