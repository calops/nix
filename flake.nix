{
  description = "Home-manager configuration";

  inputs = {
    # Upstream nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Personal fork of nixpkgs
    myNixpkgs.url = "github:calops/nixpkgs";

    # Neovim nightly packages, cached in nix-community cachix
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Nix language server
    nixd.url = "github:nix-community/nixd";

    # Theming framework for nixos and home-manager
    stylix.url = "github:danth/stylix";

    # Nix user repository
    nur.url = "github:nix-community/NUR";

    # Devshell framework and utilities
    devenv.url = "github:cachix/devenv";

    # AGS linux GUI utilities
    ags.url = "github:Aylur/ags";

    # Firefox package for darwin
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    # nh fork with darwin support
    nh-darwin.url = "github:ToyVo/nh-darwin";

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

    # Hyprland plugins
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "nixpkgs";

    # Home-manager modules
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake framework to reduce boilerplate
    snowfall-lib.url = "github:snowfallorg/lib/dev";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    # App launcher
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    # Nix fork with more up to date optimizations and features
    lix.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
    lix.inputs.nixpkgs.follows = "nixpkgs";

    # Cosmic desktop environment
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";

    # Vencord settings module (discord mod)
    nixcord.url = "github:kaylorben/nixcord";
  };

  nixConfig = {
    extra-substituters = ''
      https://nix-community.cachix.org
      https://calops.cachix.org
      https://cache.garnix.io
      https://cosmic.cachix.org
    '';
    extra-trusted-public-keys = ''
      nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
      calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0=
      cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
      cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=
    '';
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
