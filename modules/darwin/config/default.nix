{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.nh_plus.nixDarwinModules.prebuiltin ];

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

    environment = {
      systemPackages = [ pkgs.raycast ];
      shells = [ pkgs.fish ];
      variables.EDITOR = "nvim";
    };

    launchd.user.envVariables.MOZ_LEGACY_PROFILES = "1";

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
