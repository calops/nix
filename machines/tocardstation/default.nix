{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  time.timeZone = "Europe/Paris";

  my.roles = {
    terminal.enable = true;
    gaming.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
    graphical = {
      enable = true;
      nvidia.enable = true;
      installAllFonts = true;
      terminal = "kitty";
    };
  };

  boot.initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
  boot.supportedFilesystems = ["ntfs"];

  networking = {
    hostName = "tocardstation";
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "9.9.9.9"];
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

  services = {
    xserver = {
      enable = true;
      layout = "fr";
      xkbVariant = "azerty";
      desktopManager.gnome.enable = true;
    };

    printing.enable = true;

    udisks2.enable = true;
  };
  security.rtkit.enable = true;
  security.pam.services.swaylock = {};

  users.users.calops = {
    isNormalUser = true;
    description = "Rémi Labeyrie";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [pkgs.mangohud];
    extraPackages32 = [pkgs.mangohud];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true; # Enable modesetting driver
    powerManagement.enable = false; # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.finegrained = false; # Fine-grained power management. Turns off GPU when not in use.
    open = false; # Open-source drivers
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
