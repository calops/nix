{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.my.roles.printing.enable = lib.mkEnableOption "Printing";

  config = lib.mkIf config.my.roles.printing.enable {
    # Scanning
    hardware.sane.enable = true;
    hardware.sane.extraBackends = [
      pkgs.sane-airscan
      pkgs.hplipWithPlugin
    ];
    services.udev.packages = [ pkgs.sane-airscan ];
    users.users.calops.extraGroups = [
      "scanner"
      "lp"
    ];

    # Printing
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplipWithPlugin ];
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
