{
  description = "Home-manager configuration";

  inputs = {
    # Upstream nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nixpkgs fork specifically for howdy
    # TODO: remove when upstreamed
    howdy-nixpkgs.url = "github:fufexan/nixpkgs/howdy";

    # Flake framework
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    # Theming framework for nixos and home-manager
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nur.follows = "nur";

    # Nix user repository
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # AGS linux GUI utilities
    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    # Support dynamically linked binaries for generic Linux (nix-ld alternative)
    madness.url = "github:antithesishq/madness";

    # Nix-darwin modules
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Precompiled nix-index database
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Rust toolchain
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # Niri window manager
    niri-src.url = "github:yalter/niri";
    niri.url = "github:calops/niri-flake/";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    niri.inputs.niri-unstable.follows = "niri-src";

    # Home-manager modules
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # App launcher
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    # Vencord settings module (discord mod)
    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    # Logitech devices manager
    solaar.url = "github:Svenum/Solaar-Flake/main";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

    # Custom font
    aporetic.url = "github:calops/iosevka-aporetic";
    aporetic.inputs.nixpkgs.follows = "nixpkgs";

    # Personal fork of tide (upstream is unmaintained)
    fish-tide.url = "github:calops/tide";
    fish-tide.flake = false;

    # Disk formatting
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Determinate version of nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    determinate.inputs.nixpkgs.follows = "nixpkgs";

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-gaming.inputs.nixpkgs.follows = "nixpkgs";

    nh.url = "github:viperML/nh";
    nh.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    zuban.url = "github:zubanls/zuban";
    zuban.flake = false;
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;

      nixpkgs.config.allowUnfree = true;
    };
}
