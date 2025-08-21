{
  inputs,
  pkgs,
  stdenv,
}:
if stdenv.isLinux then
  inputs.niri.packages."${pkgs.system}".niri-unstable.overrideAttrs {
    doCheck = false;
  }
else
  { }
