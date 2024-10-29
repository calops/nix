{
  nur,
  myNixpkgs,
  neovim-nightly-overlay,
  nixd,
  fenix,
  darwin,
  firefox-darwin,
  devenv,
  nightly-tools,
  ...
}:
self: super:
{
  nur = import nur {
    pkgs = super;
    nurpkgs = super;
  };

  nightly = nightly-tools.overlays.default self super;

  toUpstream = import myNixpkgs { inherit (super) system config; };
}
// (neovim-nightly-overlay.overlays.default self super)
// (nixd.overlays.default self super)
// (fenix.overlays.default self super)
// (darwin.overlays.default self super)
// (devenv.overlays.default self super)
// (super.lib.optionalAttrs super.stdenv.isDarwin (firefox-darwin.overlay self super))
