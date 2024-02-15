{pkgs, ...}:
pkgs.buildGoModule rec {
  pname = "logseqlsp";
  version = "0.0.1-alpha6";

  src = pkgs.fetchFromGitHub {
    owner = "WhiskeyJack96";
    repo = "logseqlsp";
    rev = "v${version}";
    hash = "sha256-er6xPmye/mna18CNthvwyGIqIQ7B4MAw2aFb97fSmF0=";
  };

  vendorHash = "sha256-djvKn5pFObyXdmZf+8KwMA19OtbI0i3sdruhHCzmMJU=";
}
