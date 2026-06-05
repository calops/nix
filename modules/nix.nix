{
  den,
  lib,
  ...
}:
let
  nixClass =
    { aspect-chain, ... }:
    den._.forward {
      each = [
        "nixos"
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
in
{
  den.schema.user.includes = [
    nixClass
    { homeManager.nixpkgs.config.allowUnfree = true; }
    (
      { user, ... }:
      {
        nix = {
          allowed-users = [ user.userName ];

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
      }
    )
  ];

  den.schema.host.includes = [
    {
      nixos.nixpkgs.config.allowUnfree = true;
      darwin.nixpkgs.config.allowUnfree = true;
    }
  ];
}
