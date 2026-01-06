{
  age.identityPaths = ["/persistent/etc/ssh/agenix_ssh_key"];

  age.secrets = {
    darkcodiPassword = {
      file = ./age-files/darkcodi-password.age;
      path = "/run/agenix/darkcodiPassword";
      mode = "0400";
    };

    tailscale-auth-key = {
      file = ./age-files/tailscale-auth-key.age;
      path = "/run/agenix/tailscale-auth-key";
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };
}
