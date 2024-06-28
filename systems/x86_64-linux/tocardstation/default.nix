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

  virtualisation.docker.enable = true;

  boot.initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
  boot.supportedFilesystems = [ "ntfs" ];

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
