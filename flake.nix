{
  description = "Stockly dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in {
    devShells.x86_64-linux.rust = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      buildInputs = with pkgs; [
        bzip2
        cargo
        clang
        cmake
        gcc
        libclang
        libllvm
        openssl
        rust-analyzer
        rustPlatform.bindgenHook
        rustc
        zlib
      ];
    };
  };
}
