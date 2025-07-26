{ ... }:
let
  caches = import ../../lib/caches.nix;
in
{
  nix.settings = {
    lazy-trees = true;
    extra-substituters = caches.substituters;
    extra-trusted-public-keys = caches.trustedPublicKeys;

    # access-tokens = [
    #   "TODO"
    # ];

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
