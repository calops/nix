{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "hyprfreeze";

  src = pkgs.fetchFromGitHub {
    owner = "Zerodya";
    repo = "hyprfreeze";
    rev = "daffbc49c52ed1b2fcda758dd281fd04c93f5cf1";
    hash = "sha256-m+5439g+AyzUtRaFH4x8gg4qjoSva1NTdEHoTGKqyv0=";
  };

  installPhase = ''
    OUT=$out/bin
    mkdir -p $OUT
    cp -r $src/hyprfreeze $OUT
  '';

  meta.platforms = [ "x86_64-linux" ];
}
