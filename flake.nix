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
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    commonModules = [
      {
        my.stateVersion = "24.05";
        nix.settings = {
          experimental-features = ["flakes" "nix-command"];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          trusted-users = ["root" "@wheel"];
        };
      }
    ];
  in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall.namespace = "my";

      channels-config = {
        allowUnfree = true;
        overlays = [
          inputs.neovim-nightly-overlay.overlay
          inputs.nixd.overlays.default
          inputs.fenix.overlays.default
          (self: super: {
            nur = import inputs.nur {
              pkgs = super;
              nurpkgs = super;
            };
          })
        ];
      };

      systems.modules.nixos =
        commonModules
        ++ [
          inputs.stylix.nixosModules.stylix
        ];

      homes.modules = commonModules;

      outputs-builder = channels: {
        formatter = channels.nixpkgs.alejandra;
      };
    };
}
