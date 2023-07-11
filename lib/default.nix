{
  inputs,
  overlays,
  extraModules,
}: let
  home-manager = inputs.home-manager;
  nixpkgs = inputs.nixpkgs;

  mkLib = pkgs: hm:
    pkgs.lib.extend
    (self: super:
      {
        my = import ./lib.nix {
          inherit pkgs;
          lib = self;
        };
      }
      // hm.lib);

  mkHomeConfiguration = configurationName: machine:
    home-manager.lib.homeManagerConfiguration rec {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = overlays;
      };
      modules =
        extraModules
        ++ [
          ./roles
          ./programs
          ./colors
          machine
          {
            home.stateVersion = "23.11";
            # targets.genericLinux.enable = false;
          }
        ];
      extraSpecialArgs = {
        inherit inputs;
        inherit configurationName;
        lib = mkLib pkgs home-manager;
      };
    };
in {
  mkHomeConfigurations = machines: builtins.mapAttrs (name: machine: mkHomeConfiguration name machine) machines;
  mkNixosConfigurations = machines: builtins.mapAttrs (name: machine: mkNixosConfiguration name machine) machines;
  mkDevShells = shells: builtins.mapAttrs (name: shell: mkDevShell name shell) shells;
}
