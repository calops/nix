# Single source of truth for every binary cache used in this repository.
#
# Consumed by:
#   - den.default.includes below (global NixOS/Darwin `nix` settings)
#   - den.default.darwin.includes below (darwin-scoped nix-darwin cache)
#   - CI (.github/workflows): `nix eval --raw .#nixConfigText` to configure
#     runners without duplicating the list in workflow YAML
#   - anything else via `config.flake.nixConfigText`
{ den, lib, ... }:
let
  list = {
    nixos = {
      url = "https://cache.nixos.org";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    };
    calops = {
      url = "https://calops.cachix.org";
      key = "calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0=";
    };
    nix-community = {
      url = "https://nix-community.cachix.org";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    };
    numtide = {
      url = "https://cache.numtide.com";
      key = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    };
    anyrun = {
      url = "https://anyrun.cachix.org";
      key = "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s=";
    };
    niri = {
      url = "https://niri.cachix.org";
      key = "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
    };
    nix-darwin = {
      url = "https://nix-darwin.cachix.org";
      key = "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A=";
    };
  };

  # nix-darwin stays darwin-scoped; everything else is trusted on every host.
  global = builtins.removeAttrs list [ "nix-darwin" ];
  urlsOf = lib.mapAttrsToList (_: cache: cache.url);
  keysOf = lib.mapAttrsToList (_: cache: cache.key);
  nixConfLines = urls: keys: ''
    extra-substituters = ${builtins.concatStringsSep " " urls}
    extra-trusted-public-keys = ${builtins.concatStringsSep " " keys}
  '';
in
{
  # Consumed by CI: `nix eval --raw .#nixConfigText >> ~/.config/nix/nix.conf`
  # and by anything else via `config.flake.nixConfigText`.
  flake.nixConfigText = nixConfLines (urlsOf list) (keysOf list);

  den.default.includes = [
    {
      nix.extra-substituters = urlsOf global;
      nix.extra-trusted-public-keys = keysOf global;
    }
  ];

  # darwin-scoped: only nix-darwin hosts need the nix-darwin cache.
  den.default.darwin.includes = [
    {
      nix.extra-substituters = [ list.nix-darwin.url ];
      nix.extra-trusted-public-keys = [ list.nix-darwin.key ];
    }
  ];
}
