{ pkgs, lib, ... }:
let
  caches = import ../../lib/caches.nix;
in
{
  nix.package = lib.mkForce pkgs.lix;
  nix.settings = {
    extra-substituters = caches.substituters;
    extra-trusted-public-keys = caches.trustedPublicKeys;

    experimental-features = [
      "flakes"
      "nix-command"
    ];

    trusted-users = [
      "root"
      "@wheel"
      "@sudo"
      "@admin"
    ];
  };
}
