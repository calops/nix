{ flake, ... }:
{
  nix.settings = {
    extra-substituters = flake.lib.caches.substituters;
    extra-trusted-public-keys = flake.lib.caches.trustedPublicKeys;

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
