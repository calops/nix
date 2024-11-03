{ inputs, pkgs, ... }:
let
  caches = import ../../lib/caches.nix;
in
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      name = "bootstrap";

      env.NIX_CONFIG = ''
        extra-substituters = ${toString caches.substituters}
        extra-trusted-public-keys = ${toString caches.trustedPublicKeys}
      '';
    }
  ];
}
