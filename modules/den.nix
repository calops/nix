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
    den.provides.hostname
    den.provides.define-user
    den.provides.inputs'
    den.provides.self'
  ];

  den.schema.host.options.configDir = lib.mkOption {
    type = lib.types.str;
    default = "/etc/nixos";
  };

  den.schema.user = {
    classes = lib.mkDefault [ "homeManager" ];
    includes = [
      den._.mutual-provider
      den._.host-aspects
    ];
  };

  den.schema.home.includes = [
    den._.mutual-provider
  ];
}
