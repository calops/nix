{
  lib,
  config,
  ...
}: {
  options.my.roles.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

  config = lib.mkIf config.my.roles.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    services.blueman.enable = config.my.roles.graphical.enable;
  };
}
