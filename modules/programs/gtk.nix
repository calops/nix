{ ... }:
{
  den.aspects.programs.provides.gtk.includes = [
    {
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

          home.packages = [ pkgs.dconf ];
        };

      homeManagerLinux = { pkgs, ... }: {
        home.packages = [ pkgs.libsForQt5.qt5ct ];
      };
    }
  ];
}
