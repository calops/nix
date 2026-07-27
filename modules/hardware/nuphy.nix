{ ... }:
{
  den.aspects.hardware.provides.nuphy = {
    nixos = {
      services.udev.extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", MODE="0666"
      '';
    };
  };
}
