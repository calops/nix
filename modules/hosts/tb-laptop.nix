{ inputs, den, lib, pkgs, perSystem, ... }:
{
  den.hosts.x86_64-linux.tb-laptop.users.calops = {};

  den.aspects.tb-laptop = {
    includes = [
      den.aspects.base-nixos
      den.aspects.graphical
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.work-terabase
    ];

    nixos = { config, pkgs, ... }: {
      imports = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
        ../../hosts/tb-laptop/hardware.nix
      ];

      my.configDir = "/home/calops/nix";

      networking.hostName = "tb-laptop";
      time.timeZone = "Europe/Paris";

      services.xserver.xkb = {
        layout = "fr";
        variant = "azerty";
      };
      console.keyMap = "fr";

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
      boot.kernelPackages = pkgs.linuxPackages_6_18;

      services.fstrim.enable = true;

      environment.systemPackages = [ pkgs.woeusb-ng ];

      users.users.calops = {
        isNormalUser = true;
        description = "Rémi Labeyrie";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
        shell = pkgs.fish;
      };

      swapDevices = [
        { device = "/swapfile"; size = 32 * 1024; }
      ];
    };

    homeManager = { ... }: {
      my.roles.graphical = {
        enable = true;
        installAllFonts = true;
        terminal = "kitty";

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
  };
}
