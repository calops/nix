{pkgs, ...}: {
  home.packages = [pkgs.darwin-rebuild pkgs.darwin-option];
}
