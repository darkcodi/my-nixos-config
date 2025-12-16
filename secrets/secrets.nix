let
  agenix-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTPx1MpUg3RqYJJp5VmCuzTkT//y3rghBAsEas0i/VC darkcodi@misato";
in {
  "minimax-coding-plan-apikey.age".publicKeys = [agenix-pubkey];
  "nixos-misato-ssh-privkey.age".publicKeys = [agenix-pubkey];
  "nixos-misato-ssh-pubkey.age".publicKeys = [agenix-pubkey];
}
