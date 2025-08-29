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
      theme = lib.mkIf pkgs.stdenv.isLinux {
        name = lib.mkForce "Catppuccin-GTK-Dark";
        package = lib.mkForce (
          pkgs.magnetic-catppuccin-gtk.override {
            accent = [ "all" ];
            shade = "dark";
            tweaks = [
              "float"
            ];
          }
        );
      };
      iconTheme = lib.mkIf pkgs.stdenv.isLinux {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      # FIXME:
      # platformTheme.name = "qt5ct";
      # style = {
      #   name = "catppuccin-mocha-mauve";
      #   package = pkgs.catppuccin-qt5ct;
      # };
    };

    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.libsForQt5.qt5ct;
  };
}
