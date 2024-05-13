{ lib, config, ... }:
{
  options.my.roles.nvidia.enable = lib.mkEnableOption "Nvidia support";

  config = lib.mkIf config.my.roles.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

    hardware.nvidia = {
      modesetting.enable = true; # Enable modesetting driver
      powerManagement.enable = true; # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.finegrained = false; # Fine-grained power management. Turns off GPU when not in use.
      open = false; # Open-source drivers
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
}
