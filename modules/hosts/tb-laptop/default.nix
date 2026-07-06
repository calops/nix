{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.tb-laptop = {
    users.calops = { };
    configDir = "/home/calops/nix/";
  };

  den.aspects.tb-laptop = {
    includes = [
      den.aspects.laptop
      den.aspects.ai-dev
      den.aspects.work._.terabase
      den.aspects.hardware._.nuphy
      den.aspects.hardware._.logitech
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

        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.kernelModules = [
          "i2c_designware_core"
          "i2c_designware_pci"
        ];

        # Makes tap-to-click work. Temporary until upstream merges the quirk:
        # https://gitlab.freedesktop.org/libinput/libinput/-/merge_requests/1500
        environment.etc."libinput/local-overrides.quirks".text = ''
          [ELAN0676 Touchpad tap fix]
          MatchName=ELAN0676:00 04F3:3195 Touchpad
          MatchUdevType=touchpad
          AttrEventCode=-ABS_MT_TOOL_TYPE
        '';

        environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        hardware.enableRedistributableFirmware = true;

        services.fstrim.enable = true;

        swapDevices = [
          {
            device = "/swapfile";
            size = 32 * 1024;
          }
        ];
      };

    homeManager =
      { ... }:
      {
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
