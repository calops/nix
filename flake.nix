{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = inputs: let
    overlays = with inputs; [
      neovim-nightly-overlay.overlay
      nixgl.overlay
      nixd.overlays.default
      rust-overlay.overlays.default
      nur.overlay
      (import ./packages).overlay
    ];

    stateVersion = "24.05";

    machines = import ./machines;
    shells = import ./shells;
    lib = import ./lib {
      inherit inputs overlays stateVersion;
    };
  in {
    nixosConfigurations = lib.mkNixosConfigurations {tocardstation = import ./machines/tocardstation;};
    homeConfigurations = lib.mkHomeConfigurations machines;
    devShells = lib.mkDevShells shells;
  };
}
