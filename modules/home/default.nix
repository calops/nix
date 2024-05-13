{ inputs, ... }:
{
  imports = [
    ../common
    inputs.stylix.homeManagerModules.stylix
  ];
}
