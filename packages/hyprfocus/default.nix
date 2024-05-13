{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "hyprfocus";
  pname = "hyprfocus";
  meta.description = "Focus animations for Hyprland";

  src = pkgs.fetchFromGitHub {
    owner = "VortexCoyote";
    repo = "hyprfocus";
    rev = "ec3b45482f651c2b1f0e4df90a41d24a1afa5a74";
    hash = "sha256-JuUNQXUetKIUGGwzEA5dQmKtpFvYSZzG/IV373aKd6U=";
  };

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.hyprland ] ++ pkgs.hyprland.buildInputs;

  installPhase = ''
    OUT="$out/lib"
    mkdir -p $OUT
    cp hyprfocus.so $OUT/libhyprfocus.so
  '';
}
