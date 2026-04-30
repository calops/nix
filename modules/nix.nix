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
  den.ctx.user.includes = [ nixClass ];

  den.default.includes = [
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
    {
      nixos.nixpkgs.config.allowUnfree = true;
      homeManager.nixpkgs.config.allowUnfree = true;
      darwin.nixpkgs.config.allowUnfree = true;
    }
  ];
}
