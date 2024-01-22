{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixgl.url = "github:guibou/nixGL";
    nixd.url = "github:nix-community/nixd";
    rust-overlay.url = "github:oxalica/rust-overlay";
    stylix.url = "github:danth/stylix";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;
    stateVersion = "24.05";

    machines = import ./machines;
    lib = import ./lib {
      inherit inputs outputs stateVersion;
    };
  in {
    nixosConfigurations = lib.mkNixosConfigurations machines.nixos;
    homeConfigurations = lib.mkHomeConfigurations machines.home-manager;

    devShells = lib.mkDevShells import ./shells;
    homeManagerModules = import ./modules/home-manager;
    nixosModules = import ./modules/nixos;
  };
}
