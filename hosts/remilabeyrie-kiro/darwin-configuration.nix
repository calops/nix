{ flake, inputs, pkgs, ... }:
{
  imports = [
    flake.darwinModules.default
    inputs.dendritic.den.hosts.aarch64-darwin.remilabeyrie-kiro.mainModule
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  my.configDir = /Users/remilabeyrie/nix;

  system.primaryUser = "remilabeyrie";
  networking.hostName = "remilabeyrie-kiro";

  users.users.remilabeyrie = {
    home = "/Users/remilabeyrie";
    shell = pkgs.fish;
  };
}
