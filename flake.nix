{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixd.url = "github:nix-community/nixd";
    stylix.url = "github:danth/stylix";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ...} @ inputs: let
    inherit (self) outputs;
    stateVersion = "24.05";
    machines = import ./machines;
    lib = import ./lib {inherit inputs outputs stateVersion;};
  in {
    nixosConfigurations = lib.mkNixosConfigurations machines.nixos;
    homeConfigurations = lib.mkHomeConfigurations machines.home-manager;

    devShells = lib.mkDevShells (import ./shells);
    homeManagerModules = import ./modules/home-manager;
    nixosModules = import ./modules/nixos;
    overlays = (import ./packages).overlays;
  };
}
