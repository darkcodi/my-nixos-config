{ pkgs ? import <nixpkgs> { }, disko }:
let
  inherit (pkgs) lib;
  # Import and call the base disko config function
  baseDiskoConfig = (import ../hosts/misato/disko.nix) {};

  # Override for test: add keyFile for non-interactive testing
  testDiskoConfig = lib.recursiveUpdate baseDiskoConfig {
    disko.devices.disk.main.content.partitions.luks.content.settings = {
      allowDiscards = true;
      keyFile = "/tmp/secret.key";  # Only for automated testing
    };
  };
in
disko.lib.testLib.makeDiskoTest {
  inherit pkgs;
  name = "misato";
  disko-config = testDiskoConfig;
  extraTestScript = ''
    # Create the keyfile that disko expects (non-interactive)
    machine.succeed("echo 'testpassword' > /tmp/secret.key")
    machine.succeed("chmod 600 /tmp/secret.key")

    # Verify partitions were created
    machine.succeed("test -b /dev/vda1")  # EFI partition
    machine.succeed("test -b /dev/vda2")  # LUKS partition

    # Check that LUKS container was created
    machine.succeed("cryptsetup isLuks /dev/vda2")

    # Wait for the system to boot
    machine.wait_for_unit("multi-user.target")

    # Check BTRFS filesystem and subvolumes (mounted at / after boot)
    machine.succeed("btrfs subvolume list / | grep -qs 'path home$'")
    machine.succeed("btrfs subvolume list / | grep -qs 'path root$'")

    # Verify EFI partition is mounted
    machine.succeed("mountpoint /boot")
  '';
}
