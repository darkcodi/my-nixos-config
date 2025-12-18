{ pkgs ? import <nixpkgs> { }, disko }:
disko.lib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "misato";
  disko-config = ../hosts/misato/disko.nix;
  extraTestScript = ''
    # Create the keyfile that disko expects (like disko examples do)
    machine.succeed("echo 'testpassword' > /tmp/secret.key")
    machine.succeed("chmod 600 /tmp/secret.key")

    # Verify partitions were created
    machine.succeed("test -b /dev/vda1")  # EFI partition
    machine.succeed("test -b /dev/vda2")  # LUKS partition

    # Check that LUKS container was created (like disko examples)
    machine.succeed("cryptsetup isLuks /dev/vda2")

    # Wait for the system to boot if testBoot is enabled
    machine.wait_for_unit("multi-user.target")

    # Check BTRFS filesystem and subvolumes (mounted at / after boot)
    machine.succeed("btrfs subvolume list / | grep -qs 'path home$'")
    machine.succeed("btrfs subvolume list / | grep -qs 'path root$'")

    # Verify EFI partition is mounted
    machine.succeed("mountpoint /boot")
  '';
}
