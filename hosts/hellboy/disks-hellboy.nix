{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/nvme0n1";

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
                mountOptions = [ "umask=0077" ];
              };
            };

	          swap = {
		          size = "24G";
		          content = {
			          type = "swap";
			          randomEncryption = true;
		          };
	          };

            cryptroot = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot"; # device-mapper name when decrypted

                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];

		            passwordFile = "/tmp/secret.key";

                settings = {
                  allowDiscards = true;
                  #  keyFile = "/tmp/secret.key"; # Same key for both devices
                };

                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                        "ssd"
			                  "subvol=@"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                        "ssd"
			                  "subvol=@home"
                      ];
                    };
                    "@ph" = {
                      mountpoint = "/home/ph";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "ssd"
			                  "subvol=@ph"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "ssd"
			                  "subvol=@log"
                      ];
                    };
                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                        "ssd"
                        "subvol=@persist"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "ssd"
                        "subvol=@nix"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
