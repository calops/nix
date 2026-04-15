{ flake, ... }:
{
  nix.settings = {
    extra-substituters = flake.lib.caches.substituters;
    extra-trusted-public-keys = flake.lib.caches.trustedPublicKeys;

    extra-experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];

    trusted-users = [
      "root"
      "@wheel"
      "@sudo"
      "@admin"
    ];
  };
}
