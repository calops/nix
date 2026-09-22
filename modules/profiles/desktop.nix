{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "desktop" {
  includes = [
    den.aspects.graphical
    den.aspects.audio
    den.aspects.bluetooth
    den.aspects.printing
    den.aspects.input._.base
  ];

  nixos = {
    # NetworkManager pulls ModemManager in unconditionally and gives no option
    # to opt out. A desktop has no WWAN modem, so mask the unit. Masking also
    # blocks the D-Bus activation that starts it.
    systemd.services.ModemManager.enable = false;
  };
}
