{ inputs, ... }:
{
  imports = [
    ../common
    inputs.stylix.nixosModules.stylix
  ];
}
