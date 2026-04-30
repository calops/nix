{ lib, ... }:
let
  inherit (import ./_helpers.nix { inherit lib; }) mkProfileAspect;
in
mkProfileAspect "standalone" {
  homeManager.dconf.enable = false;
}
