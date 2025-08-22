{
  pkgs,
  perSystem,
}:
pkgs.neovide.overrideAttrs {
  inherit (perSystem.self) neovim;
  name = "neovide-nightly";
  doCheck = false;
}
