{
  inputs,
  inputs',
  den,
  ...
}:
{
  den.aspects.programs.nix-index = {
    flake-file.inputs = {
      nix-index-database.url = "github:nix-community/nix-index-database";
      nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    };

    homeManager = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];
      home.packages = [ inputs'.nix-index-database.packages.nix-index-with-db ];

      programs.nix-index-database.comma.enable = true;
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    nixos.imports = [ inputs.nix-index-database.nixosModules.nix-index ];
    darwin.imports = [ inputs.nix-index-database.darwinModules.nix-index ];
  };
}
