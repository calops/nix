{
  lib,
  inputs,
  ...
}: let
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.nixd.overlays.default
    inputs.fenix.overlays.default
    (self: super: {
      nur = import inputs.nur {
        pkgs = super;
        nurpkgs = super;
      };
    })
  ];
in {
  mkIfNotNull = val: lib.mkIf (val != null);
}
