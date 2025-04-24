{
  description = "Home-manager configuration";

  inputs = {
    # Upstream nixpkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nightly-tools/nixpkgs";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Nightly versions of various packages, all cached
    nightly-tools.url = "github:calops/nightly-tools";

    # Theming framework for nixos and home-manager
    stylix.url = "github:danth/stylix";
    stylix.inputs.nur.follows = "nur";

    # Nix user repository
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Devshell framework and utilities
    devenv.follows = "nightly-tools/devenv";

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
    niri.follows = "nightly-tools/niri";

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
    lix.follows = "nightly-tools/lix";

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

    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall.namespace = "my";
      channels-config.allowUnfree = true;
      channels-config.allowBroken = true; # for _1password-gui on darwin
      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
    };
}
