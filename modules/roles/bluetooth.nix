{ inputs, den, lib, ... }:
{
  den.aspects.bluetooth = {
    nixos = { ... }: {
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = true;
    };
  };
}
