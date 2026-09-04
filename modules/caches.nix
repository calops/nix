# Binary cache registry.
#
# Dendritic declaration: modules that fetch from a substituter declare it
# right where they use it:
#
#   caches.<name> = {
#     url = "https://...";
#     key = "signing-key";
#     scope = "global";   # optional: "global" (default) | "darwin"
#   };
#
# This module compiles the union into every format that needs it:
#   - den.default.includes          → host `nix` settings, by scope
#   - flake.nixConfigText           → CI (`.#nixConfigText`, see workflows)
#   - anything else                 → config.flake.nixConfigText
{
  den,
  lib,
  config,
  ...
}:
let
  urlsOf = lib.mapAttrsToList (_: cache: cache.url);
  keysOf = lib.mapAttrsToList (_: cache: cache.key);
  byScope = scope: lib.filterAttrs (_: cache: (cache.scope or "global") == scope) config.caches;
  nixConfLines = urls: keys: ''
    extra-substituters = ${builtins.concatStringsSep " " urls}
    extra-trusted-public-keys = ${builtins.concatStringsSep " " keys}
  '';
in
{
  options.caches = lib.mkOption {
    description = ''
      Binary caches declared by the modules that use them, keyed by name.
      Compiled by this module into host Nix settings (per scope) and the
      `.#nixConfigText` consumed by CI.
    '';
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          url = lib.mkOption {
            type = lib.types.str;
            description = "Substituter URL.";
          };
          key = lib.mkOption {
            type = lib.types.str;
            description = "Substituter signing key.";
          };
          scope = lib.mkOption {
            type = lib.types.enum [
              "global"
              "darwin"
            ];
            default = "global";
            description = ''
              Where the cache is trusted: "global" on every host, "darwin" only
              on nix-darwin hosts. CI and devshells always see every cache.
            '';
          };
        };
      }
    );
  };

  config = {
    # Repo-level baseline; feature modules add their own where they use them.
    caches.nixos.url = "https://cache.nixos.org";
    caches.nixos.key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    caches.calops.url = "https://calops.cachix.org";
    caches.calops.key = "calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0=";
    caches.nix-community.url = "https://nix-community.cachix.org";
    caches.nix-community.key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

    # Consumed by CI: `nix eval --raw .#nixConfigText >> ~/.config/nix/nix.conf`
    flake.nixConfigText = nixConfLines (urlsOf config.caches) (keysOf config.caches);

    den.default.includes = [
      {
        nix.extra-substituters = urlsOf (byScope "global");
        nix.extra-trusted-public-keys = keysOf (byScope "global");
      }
    ];

    den.default.darwin.includes = [
      {
        nix.extra-substituters = urlsOf (byScope "darwin");
        nix.extra-trusted-public-keys = keysOf (byScope "darwin");
      }
    ];
  };
}
