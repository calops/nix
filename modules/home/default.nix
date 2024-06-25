{ inputs, ... }:
{
  imports = [
    ../common
    inputs.stylix.homeManagerModules.stylix
    inputs.nix-index-database.hmModules.nix-index
    inputs.nh-darwin.homeManagerModules.prebuiltin
  ];
}
