{ pkgs, ... }:
{
  my.configDir = /Users/rlabeyrie/nix;

  users.users.rlabeyrie = {
    home = "/Users/rlabeyrie";
    shell = pkgs.fish;
  };

  homebrew = {
    brews = [
      "coreutils"
      "openssl"
    ];

    casks = [
      {
        name = "chromium";
        args = {
          no_quarantine = true;
        };
      }
    ];

    masApps = {
      Xcode = 497799835;
    };
  };
}
