{
  perSystem,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./aerospace.nix
    ./sketchybar
    ./skhd.nix
  ];

  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = [
      perSystem.nix-darwin.darwin-rebuild
      perSystem.nix-darwin.darwin-option
    ];
  };
}
