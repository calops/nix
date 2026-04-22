{ ... }:
{
  flake-file.inputs = {
    solaar.url = "github:Svenum/Solaar-Flake/main";
    solaar.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.hardware.logitech = {
    nixos =
      { inputs, ... }:
      {
        imports = [
          inputs.solaar.nixosModules.default
        ];

        hardware.logitech.wireless.enable = true;
        services.solaar.enable = true;
      };
  };
}
