{ ... }:
{
  flake-file.inputs.ghostty = {
    url = "github:parkers0405/ghostty-pixel-scroll";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
    };
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
          package = inputs'.ghostty.packages.default.overrideAttrs {
            # Current nixpkgs initializes Zig's cache during configurePhase.
            dontConfigure = false;
          };
        };
      };
  };
}
