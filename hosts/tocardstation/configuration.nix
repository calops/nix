{
  pkgs,
  inputs,
  flake,
  ...
}:
{
  imports = [
    inputs.solaar.nixosModules.default
    inputs.disko.nixosModules.disko
    flake.nixosModules.default
    ./hardware.nix
  ];

  networking.hostName = "tocardstation";
  time.timeZone = "Europe/Paris";

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  my.configDir = "/home/calops/nix";

  nix.settings.cores = 22; # keep two cores for the system

  my.roles = {
    graphical.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
  };

  # Adjust audio sample rate
  # services.pipewire.extraConfig.pipewire.adjust-sample-rate = {
  #   "context.properties" = {
  #     "default.clock.rate" = 92000;
  #     "default.clock.allowed-rates" = [
  #       44100
  #       48000
  #       92000
  #       192000
  #     ];
  #   };
  # };

  # Last known kernel with working wifi driver
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # SSD periodic trimming
  services.fstrim.enable = true;

  # Logitech mouse and keyboard wireless dongle
  hardware.logitech.wireless.enable = true;

  # Logitech device manager
  services.solaar.enable = true;

  boot = {
    # initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
    supportedFilesystems = [ "ntfs" ];
  };

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

  users.users.calops = {
    isNormalUser = true;
    description = "Rémi Labeyrie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "i2c"
      "vboxusers"
    ];
    shell = pkgs.fish;
  };

  networking.networkmanager.insertNameservers = [
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Virtualisation
  # virtualisation.waydroid.enable = true;
  # virtualisation.virtualbox = {
  #   host.enable = true;
  #   host.enableExtensionPack = true;
  # };
  # boot.blacklistedKernelModules = [ "kvm-intel" ]; # needed for virtualbox

  # Disks configuration
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

  systemd.sleep.extraConfig = ''
    SuspendState=freeze
  '';

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # 64 GiB
    }
  ];
}
