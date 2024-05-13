{ inputs, ... }:
{
  imports = [
    ../common
    inputs.stylix.nixosModules.stylix
    inputs.nix-index-database.nixosModules.nix-index
  ];
}
