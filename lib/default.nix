{
  inputs,
  overlays,
  stateVersion,
}: let
  home-manager = inputs.home-manager;

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = overlays;
  };

  lib =
    pkgs.lib.extend
    (self: super:
      {
        my = import ./lib.nix {
          inherit pkgs;
          lib = self;
        };
      }
      // home-manager.lib);

  mkHomeConfiguration = configurationName: machine:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        inputs.stylix.homeManagerModules.stylix
        ../cachix.nix
        ../roles
        ../home
        ../colors
        machine
      ];
      extraSpecialArgs = {
        inherit inputs configurationName stateVersion lib;
        isStandalone = true;
      };
    };

  mkNixosConfiguration = configurationName: machine:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        ../cachix.nix
        ../roles
        ../system
        ../colors
        machine
        ({config, ...}: {
          system.stateVersion = stateVersion;
          nix.settings.experimental-features = [
            "flakes"
            "nix-command"
          ];

          home-manager = {
            useUserPackages = false;
            useGlobalPkgs = true;
            extraSpecialArgs = {
              inherit inputs configurationName stateVersion lib;
              roles = config.my.roles;
              colors = config.my.colors;
            };
            users.calops.imports = [../home];
          };
        })
      ];
      specialArgs = {
        inherit inputs configurationName stateVersion lib;
        isStandalone = false;
      };
    };
in {
  mkNixosConfigurations = configs:
    lib.attrsets.mapAttrs' (host: machine: let
      configurationName = host;
    in (lib.attrsets.nameValuePair
      configurationName (mkNixosConfiguration configurationName machine)))
    configs;

  mkHomeConfigurations = configs:
    lib.attrsets.mapAttrs' (host: machine: let
      configurationName = "${machine.home.username}@${host}";
    in (lib.attrsets.nameValuePair
      configurationName (mkHomeConfiguration configurationName machine)))
    configs;

  # TODO: split each shell into its own derivation
  mkDevShells = shells: shells {inherit pkgs inputs;};
}
