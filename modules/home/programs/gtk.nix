{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enable {
    gtk = {
      enable = true;
      iconTheme = lib.mkIf (!pkgs.stdenv.isDarwin) {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      platformTheme.name = "qt5ct";
      style = {
        name = "catppuccin-mocha-mauve";
        package = pkgs.catppuccin-qt5ct;
      };
    };

    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.libsForQt5.qt5ct;
  };
}
