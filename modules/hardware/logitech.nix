{ ... }:
{
  den.aspects.hardware.provides.logitech = {
    nixos = {
      hardware.logitech.wireless.enable = true;
      programs.solaar.enable = true;

      # Grant access to Logitech USB/hidraw devices for haptic motor control.
      # These raw USB control transfers need write access to /dev/bus/usb/*.
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", MODE="0660", GROUP="wheel"
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0660", GROUP="wheel"
      '';
    };
  };
}
