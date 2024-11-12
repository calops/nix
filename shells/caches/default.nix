{ inputs, pkgs, ... }:
let
  caches = import ../../lib/caches.nix;
in
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      name = "caches";

      env.NIX_CONFIG = ''
        extra-substituters = ${toString caches.substituters}
        extra-trusted-public-keys = ${toString caches.trustedPublicKeys}
      '';
    }
  ];
}
