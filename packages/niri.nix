{
  perSystem,
  pkgs,
}:
if pkgs.stdenv.isLinux then
  perSystem.niri.niri-unstable.overrideAttrs {
    doCheck = false;
  }
else
  { }
