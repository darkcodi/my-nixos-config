let
  nixos-misato-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuWgDIgg0QUdSaGikvXmyByRomwQQmrZoMuiwg6B23L darkcodi@misato";
in {
  "minimax-coding-plan-apikey.age".publicKeys = [nixos-misato-pubkey];
}
