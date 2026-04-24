{ ... }:
{
  den.aspects.hardware.provides.nvidia = {
    nixos =
      { pkgs, config, ... }:
      {
        services.xserver.videoDrivers = [ "nvidia" ];
        boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

        hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
        hardware.nvidia = {
          modesetting.enable = true; # Enable modesetting driver
          powerManagement.enable = false; # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
          powerManagement.finegrained = false; # Fine-grained power management. Turns off GPU when not in use.
          open = true; # Open-source kernel drivers
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.beta;
        };

        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";

          # TODO: needed with the current nvidia drivers, remove when fixed
          GSK_RENDERER = "ngl";
          NVD_BACKEND = "direct";
        };
      };
  };
}
