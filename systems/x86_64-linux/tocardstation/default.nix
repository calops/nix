{ pkgs, inputs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.solaar.nixosModules.default
  ];

  networking.hostName = "tocardstation";
  time.timeZone = "Europe/Paris";

  my.configDir = "/home/calops/nix";
  my.roles = {
    graphical.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
    #monitoring.enable = true;
  };

  services.solaar.enable = true;
  hardware.logitech.wireless.enable = true;

  boot = {
    initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems = {
    "/mnt/stuff" = {
      device = "/dev/disk/by-uuid/BAC095A2C0956583";
      fsType = "ntfs";
    };
    "/mnt/games" = {
      device = "/dev/disk/by-uuid/E084CC7984CC5426";
      fsType = "ntfs";
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/405E8B6F5E8B5C92";
      fsType = "ntfs";
    };
  };

  users.users.calops = {
    isNormalUser = true;
    description = "Rémi Labeyrie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };

  networking.networkmanager.insertNameservers = [
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
    "1.1.1.1"
    "1.0.0.1"
  ];

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # Android virtualisation
  virtualisation.waydroid.enable = true;
}
