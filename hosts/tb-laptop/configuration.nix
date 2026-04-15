{
  pkgs,
  inputs,
  flake,
  ...
}:
{
  imports = [
    flake.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
    ./hardware.nix
    inputs.dendritic.den.hosts.x86_64-linux.tb-laptop.mainModule
  ];

  my.configDir = "/home/calops/nix";

  networking.hostName = "tb-laptop";
  time.timeZone = "Europe/Paris";

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
  console.keyMap = "fr";

  my.roles = {
    graphical.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
  };

  boot.supportedFilesystems = [ "ntfs" ];

  environment.systemPackages = [
    pkgs.woeusb-ng
  ];

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.intel-media-driver
      pkgs.vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  hardware.enableRedistributableFirmware = true;

  # Force touchpad to use InterTouch (RMI4/SMBus) instead of legacy PS/2
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

  # 6.19 seems to introduce a regression that throttles the cpu when plugged in
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # SSD periodic trimming
  services.fstrim.enable = true;

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

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # 64 GiB
    }
  ];
}
