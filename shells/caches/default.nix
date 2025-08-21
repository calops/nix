{ inputs, pkgs, lib, ... }:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      name = "caches";

      env.NIX_CONFIG = ''
        extra-substituters = ${toString lib.my.caches.substituters}
        extra-trusted-public-keys = ${toString lib.my.caches.trustedPublicKeys}
      '';
    }
  ];
}
