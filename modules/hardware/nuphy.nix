{ ... }:
{
  den.aspects.hardware.nuphy = {
    nixos = {
      services.xserver.xkb = {
        layout = "fr";
      };

      services.udev.extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="19f5", MODE="0666"
      '';
    };
  };
}
