{
  description = "Home-manager configuration";

  inputs = {
    # Upstream nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nightly versions of various packages
    nightly-tools.url = "github:calops/nightly-tools";

    # Theming framework for nixos and home-manager
    stylix.url = "github:danth/stylix";

    # Nix user repository
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Devshell framework and utilities
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    # AGS linux GUI utilities
    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox package for darwin
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    firefox-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Support dynamically linked binaries for generic Linux (nix-ld alternative)
    madness.url = "github:antithesishq/madness";

    # Nix-darwin modules
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Precompiled nix-index database
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Rust toolchain
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # Niri window manager
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Home-manager modules
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake framework to reduce boilerplate
    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    # App launcher
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    # Nix fork with more up to date optimizations and features
    lix.url = "git+https://git.lix.systems/lix-project/nixos-module";
    lix.inputs.nixpkgs.follows = "nixpkgs";

    # Vencord settings module (discord mod)
    nixcord.url = "github:kaylorben/nixcord/d5f2fbef2fad379190e0c7a0d2d2f12c4e4df034";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    # Logitech devices manager
    solaar.url = "github:Svenum/Solaar-Flake/main";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall.namespace = "my";
      channels-config.allowUnfree = true;
      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
    };
}
