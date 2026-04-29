{ den, lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "laptop" {
  includes = [
    den.aspects.graphical
    den.aspects.audio
    den.aspects.bluetooth
    den.aspects.printing
    den.aspects.input._.base

    {
      nixos = {
        services.logind.settings.Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
        };
      };
    }
  ];
}
