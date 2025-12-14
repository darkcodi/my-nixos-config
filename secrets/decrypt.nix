{ config, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  # Agenix configuration for user secrets
  age.identityPaths = [ "${homeDir}/.ssh/id_ed25519" ];
  age.secrets = {
    # Example secret: API key for sometool
    "sometool-apikey" = {
      file = ./sometool-apikey.age;
      path = "${homeDir}/.sometool/apikey.txt";
      mode = "0400"; # readonly
    };
  };
}
