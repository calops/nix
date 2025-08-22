{
  inputs,
  pkgs,
  flake,
  ...
}:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      name = "caches";

      env.NIX_CONFIG = ''
        extra-substituters = ${toString flake.lib.caches.substituters}
        extra-trusted-public-keys = ${toString flake.lib.caches.trustedPublicKeys}
      '';
    }
  ];
}
