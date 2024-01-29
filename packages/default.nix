let
  mkOverlay = prev: pkgNames: prev.lib.genAttrs pkgNames (name: (import ./${name}.nix prev));
in {
  overlays = {
    default = final: prev:
      mkOverlay prev [
        "catppuccin-mocha-grub-theme"
        "catppuccin-mocha-sddm-theme"
        "catppuccin-mocha-swaync-theme"
      ];
    patches = final: prev: {
      # Fix electron version
      logseq = prev.logseq.overrideAttrs (oldAttrs: {
        postFixup = ''
          makeWrapper ${prev.electron}/bin/electron $out/bin/${oldAttrs.pname} \
            --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
            --add-flags $out/share/${oldAttrs.pname}/resources/app \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
            --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [prev.stdenv.cc.cc.lib]}"
        '';
      });
    };
  };
}
