{ ... }:
{
  den.aspects.programs.gtk = {
    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        gtk = {
          enable = true;
          gtk4.theme = config.gtk.theme;
          iconTheme = lib.mkIf pkgs.stdenv.isLinux {
            name = "Papirus";
            package = pkgs.papirus-icon-theme;
          };
        };

        qt = lib.mkIf (!pkgs.stdenv.isDarwin) {
          enable = true;
        };

        home.packages = lib.optional pkgs.stdenv.isLinux pkgs.libsForQt5.qt5ct;
      };
  };
}
