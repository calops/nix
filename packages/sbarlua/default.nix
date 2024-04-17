{pkgs, ...}: let
  lua = pkgs.lua5_4_compat;
in
  pkgs.stdenv.mkDerivation {
    pname = "sbarlua";
    version = "0.1";

    src = pkgs.fetchFromGitHub {
      owner = "FelixKratz";
      repo = "SbarLua";
      rev = "29395b1928835efa1b376d438216fbf39e0d0f83";
      hash = "sha256-C2tg1mypz/CdUmRJ4vloPckYfZrwHxc4v8hsEow4RZs=";
    };

    nativeBuildInputs = with pkgs; [
      gcc
      readline
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/lua/${lua.luaversion}
      install -Dm755 ./bin/sketchybar.so $out/lib/lua/${lua.luaversion}/sketchybar.so
      install -Dm755 ./bin/sketchybar.so $out/lib/sketchybar.so
      runHook postInstall
    '';
  }
