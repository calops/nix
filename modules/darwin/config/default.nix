{ pkgs, ... }:
{
  system.stateVersion = 4;
  services.nix-daemon.enable = true;

  nix = {
    optimise.automatic = true;
    # package = pkgs.nixVersions.nix_2_17; # TODO: remove once OOS symlinks are fixed, broken as of 2.21
    gc = {
      automatic = true;
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
}
