{ inputs, den, ... }:
{
  flake-file.inputs = {
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.hosts.x86_64-linux.tocardstation = {
    users.calops = { };
    configDir = "/home/calops/nix/";
  };

  den.aspects.tocardstation = {
    includes = [
      den.aspects.desktop
      den.aspects.gaming
      den.aspects.hardware._.nuphy
      den.aspects.hardware._.logitech
      den.aspects.hardware._.nvidia
    ];

    user.extraGroups = [ "i2c" ];

    homeManager = {
      nix.settings.cores = 22; # keep two cores for the system
      niriExtraConfig = # kdl
        ''
          output "Technical Concepts Ltd 34R83Q X2452000226" {
            mode "3440x1440@170.000"
            variable-refresh-rate
          }
        '';
    };

    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware.nix
          inputs.disko.nixosModules.disko
        ];

        time.timeZone = "Europe/Paris";
        nix.settings.cores = 22; # keep two cores for the system
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.supportedFilesystems = [ "ntfs" ];
        services.fstrim.enable = true;
        networking.hostName = "tocardstation";

        networking.networkmanager.insertNameservers = [
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
          "1.1.1.1"
          "1.0.0.1"
        ];

        fileSystems = {
          "/mnt/stuff" = {
            device = "/dev/disk/by-uuid/BAC095A2C0956583";
            fsType = "ntfs";
          };
          # "/mnt/games" = {
          #   device = "/dev/disk/by-uuid/E084CC7984CC5426";
          #   fsType = "ntfs";
          # };
          "/mnt/data" = {
            device = "/dev/disk/by-uuid/405E8B6F5E8B5C92";
            fsType = "ntfs";
          };
          "/mnt/windows" = {
            device = "/dev/disk/by-uuid/606EA0BB6EA08AFC";
            fsType = "ntfs";
          };
          "/".options = [
            "noatime"
            "nodiratime"
          ];
        };

        disko.devices.disk.main = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7DPNU0XA04429Z";
          content = {
            type = "gpt";

            partitions.ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            partitions.luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "nodiratime"
                  ];
                };
              };
            };
          };
        };

        swapDevices = [
          {
            device = "/swapfile";
            size = 32 * 1024; # 64 GiB
          }
        ];
      };
  };
}
