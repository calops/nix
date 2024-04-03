{pkgs, ...}: {
  system.stateVersion = 4;
  services.nix-daemon.enable = true;

  nix = {
    optimise.automatic = true;
    package = pkgs.nixVersions.nix_2_17; # TODO: remove once OOS symlinks are fixed, broken as of 2.21
    gc = {
      automatic = true;
      interval = {Day = 7;};
      options = "--delete-older-than 7d";
    };
  };

  environment.shells = [pkgs.fish];
  environment.loginShell = pkgs.fish;

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "right";
    };

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain = {
      _HIHideMenuBar = true;
    };
  };

  services.yabai = {
    enable = true;
    config = {
      top_padding = 36;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
  };
}
