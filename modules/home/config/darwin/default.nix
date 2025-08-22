{ perSystem, ... }:
{
  imports = [
    ./aerospace.nix
    ./sketchybar
    ./skhd.nix
  ];

  home.packages = [
    perSystem.nix-darwin.darwin-rebuild
    perSystem.nix-darwin.darwin-option
  ];
}
