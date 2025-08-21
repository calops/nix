{
  inputs,
  ...
}:
self: super:
{
  nur = import inputs.nur {
    pkgs = super;
    nurpkgs = super;
  };
}
// (inputs.fenix.overlays.default self super)
// (inputs.darwin.overlays.default self super)
// super.lib.optionalAttrs super.stdenv.isDarwin (inputs.firefox-darwin.overlay self super)
