{ lib, ... }:
{
  nix.settings = {
    extra-substituters = lib.my.caches.substituters;
    extra-trusted-public-keys = lib.my.caches.trustedPublicKeys;

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
