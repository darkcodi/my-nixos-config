{
  age.identityPaths = ["/root/.ssh/agenix_ssh_key"];

  age.secrets = {
    darkcodiPassword = {
      file = ./age-files/darkcodi-password.age;
      path = "/run/agenix/darkcodiPassword";
      mode = "0400";
    };
  };
}
