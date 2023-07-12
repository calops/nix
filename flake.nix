{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hy3.url = "github:outfoxxed/hy3";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixgl.url = "github:guibou/nixGL";
    nixd.url = "github:nix-community/nixd";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    overlays = [
      inputs.neovim-nightly-overlay.overlay
      inputs.nixgl.overlay
      inputs.nixd.overlays.default
    ];

    extraModules = [
      inputs.stylix.homeManagerModules.stylix
    ];

    machines = import ./machines;
    shells = import ./shells;
    lib = import ./lib {
      inherit inputs overlays extraModules;
    };
  in {
    # nixosConfigurations = lib.mkNixosConfigurations machines;
    homeConfigurations = lib.mkHomeConfigurations machines;
    devShells = lib.mkDevShells shells;
  };
}
