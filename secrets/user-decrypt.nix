{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  age.identityPaths = ["/etc/ssh/agenix_ssh_key"];

  age.secrets = {
    minimaxCodingPlanApikey = {
      file = ./age-files/minimax-coding-plan-apikey.age;
      path = "${homeDir}/.minimax/apikey.txt";
      mode = "0400";
    };

    misatoSshPrivkey = {
      file = ./age-files/nixos-misato-ssh-privkey.age;
      path = "${homeDir}/.ssh/id_ed25519";
      mode = "0400";
    };

    misatoSshPubkey = {
      file = ./age-files/nixos-misato-ssh-pubkey.age;
      path = "${homeDir}/.ssh/id_ed25519.pub";
      mode = "0444";
    };

    zaiCodingPlanApikey = {
      file = ./age-files/zai-coding-plan-apikey.age;
      path = "${homeDir}/.zai/apikey.txt";
      mode = "0400";
    };
  };
}
