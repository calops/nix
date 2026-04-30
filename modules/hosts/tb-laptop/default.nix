{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.tb-laptop = {
    users.calops = { };
    configDir = "/home/calops/nix/";
  };

  den.aspects.tb-laptop = {
    includes = [
      den.aspects.laptop
      den.aspects.work._.terabase
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
          ./_hardware.nix
        ];

        time.timeZone = "Europe/Paris";
        services.xserver.videoDrivers = [ "modesetting" ];

        hardware.graphics = {
          enable = true;
          extraPackages = [
            pkgs.intel-media-driver
            pkgs.vpl-gpu-rt
          ];
        };

        environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        hardware.enableRedistributableFirmware = true;

        boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];
        # boot.kernelPackages = pkgs.linuxPackages_6_18;

        services.fstrim.enable = true;

        swapDevices = [
          {
            device = "/swapfile";
            size = 32 * 1024;
          }
        ];
      };

    homeManager = {
      programs.quickshell.localDev.enable = true;

      niriExtraConfig = # kdl
        ''
          output "China Star Optoelectronics Technology Co., Ltd MNE507ZA2-3 Unknown" {
            mode "3072x1920@120.000"
            focus-at-startup
            variable-refresh-rate

            layout {
              default-column-width { proportion 0.5; }
            }
          }

          output "LG Electronics LG ULTRAFINE 505NTNHGX503" {
            position x=-3072 y=0
          }
        '';
    };
  };
}
