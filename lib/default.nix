{
  inputs,
  overlays,
  extraModules,
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
      modules =
        extraModules
        ++ [
          ../roles
          ../programs
          ../colors
          machine
          {
            home.stateVersion = stateVersion;
            # targets.genericLinux.enable = false;
          }
        ];
      extraSpecialArgs = {
        inherit inputs configurationName lib;
      };
    };
in {
  # mkNixosConfigurations = machines: builtins.mapAttrs (name: machine: mkNixosConfiguration name machine) machines;
  mkHomeConfigurations = configs:
    lib.attrsets.mapAttrs' (host: machine: let
      configurationName = "${machine.home.username}@${host}";
    in (lib.attrsets.nameValuePair
      configurationName (mkHomeConfiguration configurationName machine)))
    configs;

  # TODO: split each shell into its own derivation
  mkDevShells = shells: shells {inherit pkgs inputs;};
}
