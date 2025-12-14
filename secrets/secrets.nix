let
  nixos-misato-pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErbfSfvcr9tpkG6kTJF0VI1ObdxAvBbZpnJeBH6L5vA darkcodi@misato";
in
{
  "sometool-apikey.age".publicKeys = [ nixos-misato-pubkey ];
}
