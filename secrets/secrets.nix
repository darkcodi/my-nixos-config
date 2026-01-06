let
  agenix-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTPx1MpUg3RqYJJp5VmCuzTkT//y3rghBAsEas0i/VC agenix-key";
in {
  "age-files/minimax-coding-plan-apikey.age".publicKeys = [agenix-pubkey];
  "age-files/nixos-misato-ssh-privkey.age".publicKeys = [agenix-pubkey];
  "age-files/nixos-misato-ssh-pubkey.age".publicKeys = [agenix-pubkey];
  "age-files/darkcodi-password.age".publicKeys = [agenix-pubkey];
  "age-files/zai-coding-plan-apikey.age".publicKeys = [agenix-pubkey];
  "age-files/tailscale-auth-key.age".publicKeys = [agenix-pubkey];
}
