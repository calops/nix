{
  inputs,
  outputs,
  stateVersion,
}: let
  overlays = with inputs; [
    neovim-nightly-overlay.overlay
    nixgl.overlay
    nixd.overlays.default
    rust-overlay.overlays.default
    nur.overlay
    (import ../packages).overlay
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

  commonModules = [
    ../cachix.nix
    ../roles
    ../colors
  ];

  hmModules =
    commonModules
    ++ [
      (import ../modules/home-manager).swaync
      ../home
    ];

  nixosModules =
    commonModules
    ++ [
      inputs.home-manager.nixosModules.home-manager
      ../system
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
          inputs.stylix.nixosModules.stylix
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

  # TODO: split each shell into its own derivation
  mkDevShells = shells: shells {inherit pkgs inputs;};
}
