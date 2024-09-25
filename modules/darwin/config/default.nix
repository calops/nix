{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.nh-darwin.nixDarwinModules.prebuiltin ];

  options = {
    my.configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      apply = toString;
      default = null;
      description = "Location of the nix config directory (this repo)";
    };
  };

  config = {
    system.stateVersion = 4;
    services.nix-daemon.enable = true;

    nix = {
      optimise.automatic = true;
      gc = {
        # automatic = true;
        interval = {
          Day = 7;
        };
        options = "--delete-older-than 7d";
      };
    };

    environment.systemPackages = [ pkgs.raycast ];
    environment.shells = [ pkgs.fish ];
    environment.loginShell = pkgs.fish;
    programs.fish.enable = true;
    homebrew.enable = true;
    security.pam.enableSudoTouchIdAuth = true;

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      os.flake = config.my.configDir;
    };

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
}
