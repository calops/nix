{
  nur,
  neovim-nightly-overlay,
  nixd,
  fenix,
  darwin,
  firefox-darwin,
  ...
}:
self: super:
{
  nur = import nur {
    pkgs = super;
    nurpkgs = super;
  };
}
// (neovim-nightly-overlay.overlay self super)
// (nixd.overlays.default self super)
// (fenix.overlays.default self super)
// (darwin.overlays.default self super)
// (super.lib.optionalAttrs super.stdenv.isDarwin (firefox-darwin.overlay self super))
