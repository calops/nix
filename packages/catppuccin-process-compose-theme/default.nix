{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "catppuccin-process-compose-theme";

  src = pkgs.fetchFromGitHub {
    owner = "nekowinston";
    repo = "ctp-process-compose";
    rev = "4db4b805a1bfe6b48fbf3b993b29226c515151d8";
    hash = "sha256-bxkxdhKpZYIcPjIGX/aXhl9jKXPNREmaT1eer7R/etk=";
  };

  installPhase = ''
    mkdir -p $out/
    cp -r $src/themes/* $out
  '';
}
