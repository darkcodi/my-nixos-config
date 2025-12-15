let
  nixos-misato-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjHUvGLIZRAOahVtSAd55izKOjCMf1Pc0ydiML80a4j darkcodi@misato";
in {
  "minimax-coding-plan-apikey.age".publicKeys = [nixos-misato-pubkey];
}
