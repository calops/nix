{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

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

  programs.coolercontrol.enable = true;

  virtualisation.docker.enable = true;

  boot.initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
  boot.supportedFilesystems = [ "ntfs" ];

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

  networking = {
    hostName = "tocardstation";
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  security.rtkit.enable = true;

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

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
}
