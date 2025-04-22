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

    # systemd.services =
    #   let
    #     override.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "true";
    #   in
    #   {
    #     systemd-suspend = override;
    #     systemd-hibernate = override;
    #     systemd-hybrid-sleep = override;
    #     systemd-suspend-then-hibernate = override;
    #   };
  };
}
