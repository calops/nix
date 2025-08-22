{ flake, pkgs, ... }:
{
  imports = [flake.darwinModules.default];

  nixpkgs.hostPlatform = "aarch64-darwin";

  my.configDir = /Users/remilabeyrie/nix;

  system.primaryUser = "remilabeyrie";
  networking.hostName = "remilabeyrie-kiro";

  users.users.remilabeyrie = {
    home = "/Users/remilabeyrie";
    shell = pkgs.fish;
  };

  # homebrew = {
  #   brews = [
  #     "coreutils"
  #     "openssl"
  #   ];
  #
  #   casks = [
  #     {
  #       name = "chromium";
  #       args = {
  #         no_quarantine = true;
  #       };
  #     }
  #     {
  #       name = "grishka/grishka/neardrop";
  #       args = {
  #         no_quarantine = true;
  #       };
  #     }
  #   ];
  #
  #   masApps = {
  #     Xcode = 497799835;
  #   };
  # };
}
