{pkgs ? import <nixpkgs> {}}: let
  overlays = (import ../packages).overlays;
in
  {
    inherit overlays;
    modules = import ../modules;
  }
  // overlays.default
