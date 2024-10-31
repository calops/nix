{
  nur,
  nixd,
  fenix,
  darwin,
  firefox-darwin,
  devenv,
  ...
}:
self: super:
{
  nur = import nur {
    pkgs = super;
    nurpkgs = super;
  };
}
// (nixd.overlays.default self super)
// (fenix.overlays.default self super)
// (darwin.overlays.default self super)
// (devenv.overlays.default self super)
// (super.lib.optionalAttrs super.stdenv.isDarwin (firefox-darwin.overlay self super))
