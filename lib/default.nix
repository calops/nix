{
  inputs,
  outputs,
  stateVersion,
}: let
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.nixd.overlays.default
    inputs.fenix.overlays.default
    outputs.overlays.default
    outputs.overlays.patches
    (self: super: {
      nur = import inputs.nur {
        pkgs = super;
        nurpkgs = super;
      };
    })
  ];

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    inherit overlays;
  };

  nixSettingsModule = {
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
  };

  commonModules = [
    ../options
    ../colors
    nixSettingsModule
  ];

  hmModules =
    commonModules
    ++ (builtins.attrValues outputs.homeManagerModules)
    ++ [
      ../config/home
    ];

  nixosModules =
    commonModules
    ++ (builtins.attrValues outputs.nixosModules)
    ++ [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.home-manager
      ../config/nixos
    ];

  mkHomeConfiguration = configurationName: machine:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        hmModules
        ++ [
          inputs.stylix.homeManagerModules.stylix
          machine
          {
            my.configurationName = configurationName;
            my.stateVersion = stateVersion;
          }
        ];
      extraSpecialArgs = {
        inherit inputs outputs;
      };
    };

  mkNixosConfiguration = configurationName: machine:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      system = "x86_64-linux";
      modules =
        nixosModules
        ++ [
          machine
          ({config, ...}: {
            my.configurationName = configurationName;
            my.stateVersion = stateVersion;
            home-manager = {
              useUserPackages = false;
              useGlobalPkgs = true;
              extraSpecialArgs = {
                inherit inputs outputs;
              };
              users.calops.imports = hmModules;
            };
          })
        ];
      specialArgs = {
        inherit inputs outputs;
      };
    };
in {
  mkNixosConfigurations = configs:
    pkgs.lib.attrsets.mapAttrs' (host: machine: let
      configurationName = host;
    in (pkgs.lib.attrsets.nameValuePair
      configurationName (mkNixosConfiguration configurationName machine)))
    configs;

  mkHomeConfigurations = configs:
    pkgs.lib.attrsets.mapAttrs' (host: machine: let
      configurationName = "${machine.home.username}@${host}";
    in (pkgs.lib.attrsets.nameValuePair
      configurationName (mkHomeConfiguration configurationName machine)))
    configs;

  mkDevShells = shells: {
    "x86_64-linux" = pkgs.lib.attrsets.mapAttrs (name: shell:
      inputs.devenv.lib.mkShell {
        inherit pkgs inputs;
        modules = [shell];
      })
    shells;
  };
}
