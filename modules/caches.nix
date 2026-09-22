# Binary cache registry.
#
# Dendritic declaration: modules that fetch from a substituter declare it
# right where they use it:
#
#   caches.<name> = {
#     url = "https://...";
#     key = "signing-key";
#     scope = "flake";    # optional: "flake" (default) | "global" | "darwin"
#   };
#
# This module compiles the union into every format that needs it:
#   - flake-file.nixConfig          → flake.nix `nixConfig`, every cache
#   - den.default.includes          → host `nix` settings, "global" only
#   - den.default.darwin.includes   → nix-darwin `nix` settings, "darwin" only
#
# Scope picks where a cache is trusted ambiently rather than per-flake. Keep it
# at the default unless a cache has to work before this flake is evaluated.
{
  lib,
  config,
  ...
}:
let
  urlsOf = lib.mapAttrsToList (_: cache: cache.url);
  keysOf = lib.mapAttrsToList (_: cache: cache.key);
  byScope = scope: lib.filterAttrs (_: cache: cache.scope == scope) config.caches;
in
{
  options.caches = lib.mkOption {
    description = ''
      Binary caches declared by the modules that use them, keyed by name.
      Compiled by this module into the flake's `nixConfig` and, for caches
      that need to work outside this flake, into host Nix settings.
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
              "flake"
              "global"
              "darwin"
            ];
            default = "flake";
            description = ''
              Where the cache is trusted. "flake" (the default) reaches it
              through the flake's `nixConfig`, so it dies with the input that
              needed it. "global" also writes it into every host's Nix
              settings, for caches that must work before this flake is
              evaluated. "darwin" is "global" restricted to nix-darwin hosts.

              Every scope ends up in `nixConfig`.
            '';
          };
        };
      }
    );
  };

  config = {
    # Needed before the flake evaluates, so these two are ambient everywhere.
    caches.nixos = {
      url = "https://cache.nixos.org";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      scope = "global";
    };
    caches.calops = {
      url = "https://calops.cachix.org";
      key = "calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0=";
      scope = "global";
    };
    caches.nix-community = {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };

    # Emitted into flake.nix by `nix run .#write-flake`. Consumers need
    # `--accept-flake-config`, or `accept-flake-config = true` in their Nix
    # settings, before Nix will honour these.
    flake-file.nixConfig = {
      extra-substituters = urlsOf config.caches;
      extra-trusted-public-keys = keysOf config.caches;
    };

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
