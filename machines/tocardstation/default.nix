{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware.nix];

  time.timeZone = "Europe/Paris";

  my.roles = {
    terminal.enable = true;
    graphical = {
      enable = true;
      nvidia.enable = true;
      installAllFonts = true;
      terminal = "kitty";
    };
    gaming.enable = false;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices.rootDrive.device = "/dev/disk/by-uuid/ab146bd7-2e99-4aa7-a115-040df4acc43d";
  };

  networking = {
    hostName = "tocardstation";
    networkmanager.enable = true;
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
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

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
}
