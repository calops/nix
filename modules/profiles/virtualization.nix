{ lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "virtualization" {
  nixos = {
    virtualisation.waydroid.enable = true;
    virtualisation.virtualbox = {
      host.enable = true;
      host.enableExtensionPack = true;
    };
    boot.blacklistedKernelModules = [ "kvm-intel" ];
  };
}
