{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.url = "github:vic/flake-file";
  };

  imports = [
    inputs.den.flakeModule
    inputs.den.flakeModules.dendritic
    inputs.flake-file.flakeModules.dendritic
  ];

  den.default.includes = [
    den.provides.define-user
    den.provides.inputs'
    den.provides.self'

    {
      nix.extra-substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org"
        "https://calops.cachix.org"
        "https://nix-community.cachix.org"
      ];
      nix.extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    }
  ];

  den.schema.host = {
    options.configDir = lib.mkOption {
      type = lib.types.str;
    };
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.ctx.user.includes = [
    den._.mutual-provider
    den._.host-aspects
  ];
}
