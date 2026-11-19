{ ... }:
{
  flake-file.inputs.sable.url = "github:SableClient/sable-next";
  flake-file.inputs.sable.inputs.nixpkgs.follows = "nixpkgs";

  den.aspects.programs.provides.sable = {
    homeManager =
      { inputs', ... }:
      {
        home.packages = [ inputs'.sable.packages.sable-desktop ];
      };
  };
}
