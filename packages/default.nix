let
  mkOverlay = prev: pkgNames: prev.lib.genAttrs pkgNames (name: (import ./${name}.nix prev));
in {
  overlay = final: prev:
    mkOverlay prev [
      "catppuccin-mocha-grub-theme"
      "catppuccin-mocha-sddm-theme"
      "catppuccin-mocha-swaync-theme"
    ];
}
