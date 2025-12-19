{...}: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:17.0-ata-2";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "luks-root";
                initrdUnlock = true;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=@"];
                    };
                    "@persistent" = {
                      mountpoint = "/persistent";
                      mountOptions = ["subvol=@persistent"];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=@nix"];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=@home"];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
