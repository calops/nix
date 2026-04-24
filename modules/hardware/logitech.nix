{ inputs, ... }:
{
  flake-file.inputs = {
    solaar.url = "github:Svenum/Solaar-Flake/main";
    solaar.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.hardware.provides.logitech = {
    nixos =
      { ... }:
      {
        imports = [
          inputs.solaar.nixosModules.default
        ];

        hardware.logitech.wireless.enable = true;
        services.solaar.enable = true;
      };
  };
}
