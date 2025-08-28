# TODO: remove once upstream is updated

{ pkgs }:
pkgs.gemini-cli.overrideAttrs (
  final: prev: rec {
    pname = "gemini-cli";
    version = "0.3.0-preview.1";

    src = pkgs.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = version;
      hash = "sha256-zbN/4jJK9167BjqYh6Mtqa4RNQyU4YXuTamHmGYTKSI=";
    };

    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      hash = "sha256-wOQUkrThQQdR0Wq9R2LTJg9Ld38BfdO8LlwdewaWtow=";
    };
  }
)
