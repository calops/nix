{ inputs, ... }:
{
  imports = [
    ../common
    inputs.stylix.homeManagerModules.stylix
    inputs.nix-index-database.hmModules.nix-index
  ];
}
