{ den, ... }:
{
  flake-file.inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.default.darwin.includes = [ den.aspects.darwin ];

  den.aspects.darwin = {
    nix.extra-substituters = [ "https://nix-darwin.cachix.org" ];
    nix.extra-trusted-public-keys = [
      "nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A="
    ];

    darwin =
      { config, pkgs, ... }:
      {
        system.stateVersion = 4;

        environment.etc."nix/nix.custom.conf".text = ''
          trusted-users = ${builtins.concatStringsSep " " config.nix.settings.trusted-users}

          extra-substituters = ${builtins.concatStringsSep " " config.nix.settings.extra-substituters}

          extra-trusted-public-keys = ${builtins.concatStringsSep " " config.nix.settings.extra-trusted-substituters}

          extra-experimental-features = ${builtins.concatStringsSep " " config.nix.settings.extra-experimental-features}
        '';

        environment = {
          shells = [ pkgs.fish ];
          variables.EDITOR = "nvim";
          variables.MOZ_LEGACY_PROFILES = "1";
        };

        programs.fish.enable = true;
        homebrew.enable = true;
        security.pam.services.sudo_local.touchIdAuth = true;

        system.defaults = {
          dock = {
            autohide = true;
            orientation = "right";
            mru-spaces = false;
          };

          finder = {
            AppleShowAllExtensions = true;
            FXEnableExtensionChangeWarning = false;
          };

          NSGlobalDomain = {
            _HIHideMenuBar = true;
          };
        };
      };

    homeManagerDarwin =
      { inputs', ... }:
      {
        home.packages = [
          inputs'.nix-darwin.packages.darwin-rebuild
          inputs'.nix-darwin.packages.darwin-option
        ];
      };
  };
}
