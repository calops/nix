{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.solaar.nixosModules.default
    inputs.disko.nixosModules.disko
  ];

  networking.hostName = "tocardstation";
  time.timeZone = "Europe/Paris";

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  my.configDir = "/home/calops/nix";

  nix.settings.cores = 30; # keep two cores for the system

  my.roles = {
    graphical.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
  };

  # SSD periodic trimming
  services.fstrim.enable = true;

  # Logitech mouse and keyboard wireless dongle
  hardware.logitech.wireless.enable = true;

  # Logitech device manager
  services.solaar.enable = true;

  boot = {
    initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems =
    let
      options = [
        "noatime"
        "nodiratime"
      ];
    in
    {
      "/mnt/stuff" = {
        inherit options;
        device = "/dev/disk/by-uuid/BAC095A2C0956583";
        fsType = "ntfs";
      };
      "/mnt/games" = {
        inherit options;
        device = "/dev/disk/by-uuid/E084CC7984CC5426";
        fsType = "ntfs";
      };
      "/mnt/data" = {
        inherit options;
        device = "/dev/disk/by-uuid/405E8B6F5E8B5C92";
        fsType = "ntfs";
      };
      "/".options = options;
    };

  users.users.calops = {
    isNormalUser = true;
    description = "Rémi Labeyrie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "i2c"
    ];
    shell = pkgs.fish;
  };

  networking.networkmanager.insertNameservers = [
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Android virtualisation
  virtualisation.waydroid.enable = true;

  # Disks configuration
  # disko.devices = {
  #   disk = {
  #     main = {
  #       # When using disko-install, we will overwrite this value from the commandline
  #       device = "/dev/disk/by-id/some-disk-id";
  #       type = "disk";
  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           MBR = {
  #             type = "EF02"; # for grub MBR
  #             size = "1M";
  #             priority = 1; # Needs to be first partition
  #           };
  #           ESP = {
  #             type = "EF00";
  #             size = "500M";
  #             content = {
  #               type = "filesystem";
  #               format = "vfat";
  #               mountpoint = "/boot";
  #               mountOptions = [ "umask=0077" ];
  #             };
  #           };
  #           root = {
  #             size = "100%";
  #             content = {
  #               type = "filesystem";
  #               format = "ext4";
  #               mountpoint = "/";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
