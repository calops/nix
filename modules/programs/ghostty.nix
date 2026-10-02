{ ... }:
{
  flake-file.inputs.ghostty = {
    url = "github:parkers0405/ghostty-pixel-scroll";
    # Keep the fork's nixpkgs pin: its Zig build needs the older cache setup hook.
    inputs.home-manager.follows = "home-manager";
  };

  caches.ghostty-pixel-scroll = {
    url = "https://ghostty-pixel-scroll.cachix.org";
    key = "ghostty-pixel-scroll.cachix.org-1:vkWtQpi2OeQk5pzrpOAEF+FHm6b6PjKoypJBbYiZMuU=";
  };

  den.aspects.programs.provides.ghostty = {
    homeManager =
      { inputs', ... }:
      {
        programs.ghostty = {
          enable = true;
          package = inputs'.ghostty.packages.default;
        };
      };
  };
}
