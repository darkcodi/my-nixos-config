{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  age.identityPaths = ["${homeDir}/.ssh/agenix_ssh_key"];

  age.secrets = {
    minimaxCodingPlanApikey = {
      file = ./minimax-coding-plan-apikey.age;
      path = "${homeDir}/.minimax/apikey.txt";
      mode = "0400"; # readonly
    };
  };
}
