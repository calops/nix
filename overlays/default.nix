{
  nur,
  neovim-nightly-overlay,
  nixd,
  fenix,
  ...
}: self: super:
{
  nur = import nur {
    pkgs = super;
    nurpkgs = super;
  };
}
// (neovim-nightly-overlay.overlay self super)
// (nixd.overlays.default self super)
// (fenix.overlays.default self super)
