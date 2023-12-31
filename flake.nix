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
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixgl.url = "github:guibou/nixGL";
    nixd.url = "github:nix-community/nixd";
    rust-overlay.url = "github:oxalica/rust-overlay";
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs: let
    overlays = with inputs; [
      neovim-nightly-overlay.overlay
      nixgl.overlay
      nixd.overlays.default
      rust-overlay.overlays.default
    ];

    extraModules = [
      inputs.stylix.homeManagerModules.stylix
    ];

    stateVersion = "24.05";

    machines = import ./machines;
    shells = import ./shells;
    lib = import ./lib {
      inherit inputs overlays extraModules stateVersion;
    };
  in {
    # nixosConfigurations = lib.mkNixosConfigurations machines;
    homeConfigurations = lib.mkHomeConfigurations machines;
    devShells = lib.mkDevShells shells;
  };
}
