{
  den,
  lib,
  ...
}:
let
  homeSettings = [
    { homeManager.nixpkgs.config.allowUnfree = true; }
    {
      homeManager =
        { config, ... }:
        {
          nix.settings = {
            allowed-users = [ config.home.username ];

            # Lets this flake's `nixConfig` supply its own substituters.
            accept-flake-config = true;

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
        };
    }
  ];
in
{
  den.aspects.nixForwardNixos =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "nixos"
      ];
      fromClass = _: "nix";
      intoClass = lib.id;
      intoPath = _: [
        "nix"
        "settings"
      ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = lib.id;
    };

  den.aspects.nixForwardHM =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "homeManager"
      ];
      fromClass = _: "nix";
      intoClass = lib.id;
      intoPath = _: [
        "nix"
        "settings"
      ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = lib.id;
    };

  den.schema.user.includes = homeSettings;
  den.schema.home.includes = [
    den.aspects.nixForwardHM
  ]
  ++ homeSettings;

  den.schema.host.includes = [
    den.aspects.nixForwardNixos
    {
      nixos.nix.settings.trusted-users = [
        "@wheel"
        "@sudo"
      ];
      nixos.nixpkgs.config.allowUnfree = true;
      darwin.nixpkgs.config.allowUnfree = true;
    }
  ];
}
