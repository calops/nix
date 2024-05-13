{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "catppuccin-mocha-swaync-theme";

  src = pkgs.fetchurl {
    url = "http://github.com/catppuccin/swaync/releases/download/v0.1.2.1/mocha.css";
    hash = "sha256-2263JSGJLu2HyHQRsFt14NSFfYj0t3h52KoE3fYL5Kc=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/
    cp $src $out/style.css
  '';
}
